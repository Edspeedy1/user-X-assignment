ArrayList<Fish> fishSchool = new ArrayList<Fish>();
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
ArrayList<Food> foodList = new ArrayList<Food>();
PImage[] fishImages;
PImage backdrop;
PImage scaledBackdrop;
PImage obstacleImg;

int fishCount = 20;

void setup() {
  size(800, 600, P2D); // P2D for transparent PNG
  // load fish images
  int fishImageCount = 23;
  fishImages = new PImage[fishImageCount];
  
  int crop = 10; // pixels to be removed (each side)
  int displayWidth = 40;  // desired width
  int displayHeight = 0;  // maintain aspect ratio
  
  backdrop = loadImage("aquarium.jpeg");
  obstacleImg = loadImage("rock.png");
  
  for (int i = 0; i < fishImageCount; i++) {
     PImage original = loadImage("fishpics/" + i + ".png");  // load images
     int newWidth = original.width - crop * 2;                 
     int newHeight = original.height - crop * 2;   
     PImage cropped = original.get(crop, crop, newWidth, newHeight);  // crop
     cropped.resize(displayWidth, displayHeight);
     fishImages[i] = cropped;  // store in array
  }
  // Create some fish
  for (int i = 0; i < fishCount; i++) {
  PImage img = fishImages[int(random(fishImages.length))];
  fishSchool.add(new Fish(random(width), random(height), 0.4 + random(1), img, 0.6 + random(1)));
}
  // Create some obstacles
  obstacles.add(new Obstacle(new PVector(300, 300), 50));
  obstacles.add(new Obstacle(new PVector(500, 500), 40));
  
}

void draw() {
  background(173, 216, 230);
  image(backdrop, width/2, height/2, width, height);

  // display food
  for (Food f : foodList) {
   f.display(); 
  }
  // Update and display fish
  fill(255);
  for (Fish f : fishSchool) {
    f.brain.setObstacles(obstacles);  // Fish brain knows about the obstacles
    f.brain.setFood(foodList);
    f.update();  // Update the fish's brain
    f.display();  // Draw the fish
  }

  // Display obstacles
  fill(220,180,190);
  for (Obstacle o : obstacles) {
    o.display(obstacleImg);
  }
}

void mousePressed() {
  foodList.add(new Food(mouseX, mouseY)); // Drop food where mouse clicked
}
