class Obstacle {
  PVector position;
  float size; // radius

  Obstacle(PVector position, float size) {
    this.position = position;
    this.size = size;
  }

  void display(PImage img) {
    ellipse(position.x, position.y, size*2-6, size*2-6);
    image(img, position.x, position.y, size*2, size*2);
  }
}

class Food{
   PVector position;
   float size;
   
   Food(float x, float y) {
    position = new PVector(x, y);
    size = 8; // food particle
   }
   
   void display() {
    noStroke();
    fill(255, 200, 0); // yellow color
    ellipse(position.x, position.y, size, size);
   }
}
