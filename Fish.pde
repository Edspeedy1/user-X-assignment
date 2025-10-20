class Fish {
  PVector position;
  PVector velocity;
  float speed;
  float size;
  FishBrain brain;
  PImage img; 
  float[] behaviorWeights;  // Array of weights for behaviors
  float behaviorChangeInterval;  // Time in seconds to change behavior
  float lastBehaviorChangeTime;  // Timer to track behavior change
  String currentBehavior;  // Current behavior
  
  float lastWanderChangeTime = 0;       // Timer for wander direction change
  float wanderChangeInterval = 1000;    // Interval in milliseconds (1 second)

  Fish(float x, float y, float speed, PImage img, float size) {
    this.position = new PVector(x, y);
    this.velocity = new PVector(0, 0);
    this.speed = speed;
    this.brain = new FishBrain(this);  // Each fish has its own brain
    this.img = img;  // display fish
    this.size = size;
    this.behaviorWeights = new float[] { 0.2, 0.5, 0.3 };  // Default weights [seeking, wandering, avoiding]
    this.behaviorChangeInterval = 1.7;  // Default to change behavior 
    this.lastBehaviorChangeTime = millis();  // Initialize the timer
    this.currentBehavior = selectBehavior();  // Initialize with a behavior
  }

  void update() {
    // Check if it's time to change the behavior
    if (millis() - lastBehaviorChangeTime > behaviorChangeInterval * 1000) {
      currentBehavior = selectBehavior();  // Select new behavior based on weights
      lastBehaviorChangeTime = millis();  // Reset the timer
    }

    brain.setBehavior(currentBehavior);  // Update the brain with the current behavior
    
    brain.setFood(foodList);
    PVector move = brain.update();  // Get vector movement
    velocity.lerp(move, 0.1);       // adjust velocity for sharper movement
    position.add(velocity);         // Moves the fish
    
    // keep fish outside obstacles
    for (Obstacle obs : brain.obstacles) {
      float dist = PVector.dist(position, obs.position);
      float minDist = obs.size + 10; // safety margin
      if (dist < minDist && dist > 0) {
        PVector pushOut = PVector.sub(position, obs.position);
        pushOut.normalize();
        pushOut.mult(minDist - dist);
        position.add(pushOut);
      }
    }
    
    // wall avoidance
    float margin = 30;
    float turnStrength = 0.05;
    
    // Left wall
    if (position.x < margin) {
     velocity.x += turnStrength;
     position.x = margin;
     brain.setBehavior("seeking");
    }
    // Right wall
    if (position.x > width - margin) {
     velocity.x -= turnStrength;
     position.x = width - margin;
     brain.setBehavior("seeking");
    }
    // Top wall
    if (position.y < margin) {
     velocity.y += turnStrength;
     position.y = margin;
     brain.setBehavior("seeking");
    }
    // Bottom wall
    if (position.y > height - margin) {
     velocity.y -= turnStrength;
     position.y = height - margin;
     brain.setBehavior("seeking");
    }
  }

  // Select a behavior based on weighted probability
  String selectBehavior() {
    float rand = random(1);  // Random number between 0 and 1
    float cumulative = 0;

    // Cumulative distribution to select behavior based on weights
    for (int i = 0; i < behaviorWeights.length; i++) {
      cumulative += behaviorWeights[i];
      if (rand <= cumulative) {
        switch (i) {
          case 0: return "seeking";
          case 1: return "wandering";
          case 2: return "avoiding";
        }
      }
    }
    return "wandering";  // Default fallback
  }

  void display() {
    imageMode(CENTER);                            
    pushMatrix();                                 //  Save current coordinate
    translate(position.x, position.y);            //  move origin of fish position
    
    // Only rotate if velocitiy is significant
    if (velocity.mag() > 0.01) {
      float angle = atan2(velocity.y, velocity.x); 
      
      float deg = degrees(angle);    
      if (90 > deg && deg > -90) {
        scale(-1, 1);
        rotate(radians(-deg)); 
      } else {
        rotate(radians(deg + 180)); 
      }
    }
    
    scale(this.size, this.size);
    image(img, 0, 0);                             //  Draw Fish
    popMatrix();                                  //  Restore coordinates
  }
 }
