import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule } from '@ionic/angular';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.page.html',
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule],
})
export class DashboardPage implements OnInit {
  public theme: String = 'dark';
  constructor() {}
  changeTheme(e: any) {
    if (this.theme == 'dark') this.theme = 'light';
    else this.theme = 'dark';
    const html: HTMLElement | null = document.querySelector('html');
    html?.setAttribute('data-theme', this.theme.toString());
    localStorage.setItem('theme', this.theme.toString());
  }
  ngOnInit() {
    const theme_data = localStorage.getItem('theme');
    if (theme_data != undefined && theme_data != null) this.theme = theme_data;
  }
}
