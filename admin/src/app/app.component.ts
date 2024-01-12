import { Component } from '@angular/core';
import { IonApp, IonRouterOutlet } from '@ionic/angular/standalone';

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  standalone: true,
  imports: [IonApp, IonRouterOutlet],
})
export class AppComponent {
  constructor() {}
  ngOnInit() {
    console.log('Init')
    const theme_data = localStorage.getItem('theme')
    if(theme_data != undefined && theme_data != null) document.querySelector('html')?.setAttribute('data-theme', theme_data)
  }
}
