package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os/exec"

	htgotts "github.com/hegedustibor/htgo-tts"
)

type SpeechRequest struct {
	Text string `json:"text"`
}

func main() {
	http.HandleFunc("/speech", speechHandler)
	log.Println("Server started on :8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

func speechHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Only POST method is accepted", http.StatusMethodNotAllowed)
		return
	}
	var req SpeechRequest
	decoder := json.NewDecoder(r.Body)
	if err := decoder.Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	speech := htgotts.Speech{Folder: "audio", Language: "id"}
	filename := "speech_output"
	mp3FilePath, err := speech.CreateSpeechFile(req.Text, filename)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	wavFilePath := "audio/ninno_speech.wav"
	cmd := exec.Command("ffmpeg", "-i", mp3FilePath, wavFilePath)
	err = cmd.Run()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"url": wavFilePath,
	})
}
