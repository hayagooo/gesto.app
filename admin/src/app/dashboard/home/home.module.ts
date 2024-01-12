import { IonicModule } from '@ionic/angular';
import { NgModule } from "@angular/core";
import { RouterModule } from "@angular/router";
import { HomeComponent } from "./home.component";

@NgModule({
  imports: [IonicModule, RouterModule.forChild([
    {
      path: '',
      component: HomeComponent
    }
  ])],
  declarations: [HomeComponent],
  exports: [HomeComponent]
})

export class HomeModule {}
