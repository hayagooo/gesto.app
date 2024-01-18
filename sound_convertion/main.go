package main

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"

	firebase "firebase.google.com/go"
	htgotts "github.com/hegedustibor/htgo-tts"
	"google.golang.org/api/option"
)

type SpeechRequest struct {
	Text   string `json:"text"`
	Number int    `json:"number"`
}

func main() {
	http.HandleFunc("/speech", speechHandler)
	http.HandleFunc("/read", readWavFile)
	log.Println("Server started on :8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

func initializeApp() *firebase.App {
	opt := option.WithCredentialsFile("gesto-d6223-firebase-adminsdk-9c3k3-97f633b21d.json")
	config := &firebase.Config{ProjectID: "gesto-d6223"}
	app, err := firebase.NewApp(context.Background(), config, opt)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}
	return app
}

func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE, PUT")
	(*w).Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")
}

func formatText(input string) string {
	lowecased := strings.ToLower(input)
	formatted := strings.ReplaceAll(lowecased, " ", "-")
	return formatted
}

func uploadFile(app *firebase.App, bucketName string, fileName string) {
	ctx := context.Background()
	client, err := app.Storage(ctx)
	if err != nil {
		log.Fatalf("error getting Storage client: %v\n", err)
	}
	// bucket, err := client.Bucket(bucketName)
	bucket, err := client.Bucket(bucketName)
	if err != nil {
		log.Fatalf("error getting default bucket: %v\n", err)
	}
	file, err := os.Open(fileName)
	if err != nil {
		log.Fatalf("error opening file: %v\n", err)
	}
	defer file.Close()

	wc := bucket.Object(fileName).NewWriter(ctx)
	if _, err = io.Copy(wc, file); err != nil {
		log.Fatalf("error writing to storage: %v\n", err)
	}
	if err := wc.Close(); err != nil {
		log.Fatalf("error closing writer: %v\n", err)
	}
	fmt.Printf("Uploaded %v to firebase storage\n", fileName)
}

func downloadFile(app *firebase.App, bucketName string, fileName string) error {
	ctx := context.Background()
	client, err := app.Storage(ctx)
	if err != nil {
		return err
	}
	bucket, err := client.Bucket(bucketName)
	if err != nil {
		return err
	}
	rc, err := bucket.Object(fileName).NewReader(ctx)
	if err != nil {
		return err
	}
	defer rc.Close()
	outputFile, err := os.Create(fileName)
	if err != nil {
		return nil
	}
	defer outputFile.Close()
	if _, err := io.Copy(outputFile, rc); err != nil {
		return err
	}
	return nil
}

func convertWavToHex(fileName string) (string, error) {
	fileData, err := os.ReadFile(fileName)
	if err != nil {
		return "", err
	}
	hexData := hex.EncodeToString(fileData)
	return hexData, nil
}

func speechHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	app := initializeApp()

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != "POST" {
		http.Error(w, "Only POST method is accepted", http.StatusMethodNotAllowed)
		return
	} else {
		var req SpeechRequest
		decoder := json.NewDecoder(r.Body)
		if err := decoder.Decode(&req); err != nil {
			log.Println("Error reading body:", err)
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		speech := htgotts.Speech{Folder: "audio", Language: "id"}
		filename := strconv.Itoa(req.Number) + "_" + formatText(req.Text)
		mp3FilePath, err := speech.CreateSpeechFile(req.Text, filename)
		if err != nil {
			log.Println("Error MP3:", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		wavFilePath := "audio/" + filename + ".wav"
		cmd := exec.Command("ffmpeg", "-y", "-i", mp3FilePath, wavFilePath)
		err = cmd.Run()
		if err != nil {
			log.Println("Error WAV:", mp3FilePath)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"url": wavFilePath,
		})
		uploadFile(app, "gesto-d6223.appspot.com", wavFilePath)
	}
}

func readWavFile(w http.ResponseWriter, r *http.Request) {
	// enableCors(&w)
	app := initializeApp()
	queryValue := r.URL.Query()
	filename := queryValue.Get("filename")
	if filename == "" {
		http.Error(w, "Filename is required", http.StatusBadRequest)
		return
	}
	wavFilePath := filepath.Join("audio", filename)
	downloadFile(app, "gesto-d6223.appspot.com", wavFilePath)
	// hexData, err := convertWavToHex(wavFilePath)
	// if err != nil {
	// 	http.Error(w, err.Error(), http.StatusInternalServerError)
	// 	return
	// }
	data, err := os.ReadFile(wavFilePath)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error reading file: %v", err), http.StatusInternalServerError)
		return
	}
	sampleData := "{\n"
	for i, b := range data {
		sampleData += fmt.Sprintf("0x%02X, ", b)
		if (i+1)%12 == 0 {
			sampleData += "\n"
		}
	}
	sampleData += "};"
	jsonResponse := map[string]string{
		// "hex":   hexData,
		"audio": sampleData,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(jsonResponse)
}
