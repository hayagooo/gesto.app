import { Component } from '@angular/core';
import { IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon } from '@ionic/angular/standalone';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  standalone: true,
  imports: [IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonIcon],
})

export class HomePage {
  public theme : String = 'dark'
  constructor() {}
  changeTheme(e: any) {
    if (this.theme == 'dark') this.theme = 'light'
    else this.theme = 'dark'
    const html: HTMLElement | null = document.querySelector('html')
    html?.setAttribute('data-theme', this.theme.toString())
    localStorage.setItem('theme', this.theme.toString())
  }
  ngOnInit() {
    const theme_data = localStorage.getItem('theme')
    if(theme_data != undefined && theme_data != null) this.theme = theme_data
  }
}
