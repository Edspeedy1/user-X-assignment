float margin = 50; // same as in Fish file

class FishBrain {
  Fish fish;
  PVector target;
  ArrayList<Obstacle> obstacles;
  String behavior;
  int ranAway;

  // Food list known to the brain
  ArrayList<Food> foodList;

  // persistent wander heading
  PVector wanderDir = PVector.random2D();

  // Predator (mouse) avoidance settings
  float predatorRadius = 140;   // how far the fish sense the cursor
  float predatorBoost  = 1.6;   // extra speed when very close

  FishBrain(Fish f) {
    this.fish = f;
    this.behavior = "wandering";
    newTarget();
    this.obstacles = new ArrayList<Obstacle>();
    this.foodList = new ArrayList<Food>();
    this.ranAway = 0;
  }

  void newTarget() {
    this.target = new PVector(margin + random(width-(2*margin)), margin + random(height-(2*margin)));
  }

  void setObstacles(ArrayList<Obstacle> obs) {
    obstacles = (obs != null) ? obs : new ArrayList<Obstacle>();
  }

  void setFood(ArrayList<Food> foodList) {
    this.foodList = (foodList != null) ? foodList : new ArrayList<Food>();
  }

  void setBehavior(String newBehavior) {
    behavior = newBehavior;
  }

  PVector update() {
    // Highest priority: flee from the cursor
    PVector flee = avoidPredator();
    if (flee.magSq() > 0) return flee;

    // 2) if there's food, go for the closest one
    if (foodList != null && !foodList.isEmpty()) {
      Food nearest = findNearestFood();
      if (nearest != null) {
        target = nearest.position.copy();
        PVector move = seekTarget();

        float dist = PVector.dist(fish.position, nearest.position);
        if (dist < nearest.size + 5) {
          foodList.remove(nearest);
        }
        return move;
      }
    }

    // 3) Otherwise, follow current behavior
    if ("seeking".equals(behavior)) {
      return seekTarget();
    } else if ("avoiding".equals(behavior)) {
      PVector avoid = avoidObstacles();
      return (avoid.magSq() > 0) ? avoid : wander();
    } else {
      return wander();
    }
  }

  // Flee from the cursor
  PVector avoidPredator() {
    int runAwayTime = 1000;
    int runAwayCooldown = 50;
    // Processing globals: mouseX, mouseY
    PVector predator = new PVector(mouseX, mouseY);
    float d = PVector.dist(fish.position, predator);
    
    ranAway = ranAway + 1; 
    
    if (ranAway > 0 && ranAway < runAwayCooldown){ 
      // ran away too soon and isnt scared anymore
      // prevents weird jitters
      return new PVector(0, 0);
    }

    if (d < predatorRadius) {
      PVector away = PVector.sub(fish.position, predator);
      if (away.magSq() == 0) away = PVector.random2D(); // edge case overlap
      away.normalize();

      // Scale speed from (1+boost)*speed at d=0 down to 1*speed at edge
      float scale = map(d, 0, predatorRadius, 1.0 + predatorBoost, 1.0);
      away.mult(fish.speed * scale);

      // Tiny jitter to look more organic under stress
      away.add(PVector.random2D().mult(0.05 * fish.speed));
      if (ranAway > runAwayCooldown){
        ranAway = -runAwayTime;
      }
      return away;
    }
    
    if (ranAway < 0){
      ranAway = 0;
    }
    return new PVector(0, 0);
  }

  PVector seekTarget() {
    if (target == null) newTarget();
    PVector toTarget = PVector.sub(target, fish.position);
    float d = toTarget.mag();
    if (d < 1) {
      target.set(random(width), random(height));
      return wander();
    }
    toTarget.normalize();
    float maxSpeed = fish.speed;
    float desiredSpeed = (d < 80) ? map(d, 0, 80, 0, maxSpeed) : maxSpeed;
    return toTarget.mult(desiredSpeed);
  }

  PVector wander() {
    PVector jitter = PVector.random2D().mult(0.12);
    wanderDir.add(jitter);
    if (wanderDir.magSq() == 0) wanderDir = PVector.random2D();
    wanderDir.normalize().mult(fish.speed);
    return wanderDir.copy();
  }

  PVector avoidObstacles() {
    if (obstacles == null || obstacles.isEmpty()) return new PVector(0, 0);
    PVector avoidForce = new PVector(0, 0);
    for (Obstacle obs : obstacles) {
      if (obs == null) continue;
      float dist = PVector.dist(fish.position, obs.position);
      if (dist > 0 && dist < obs.size) {
        PVector away = PVector.sub(fish.position, obs.position);
        away.normalize();
        away.mult((obs.size - dist) / obs.size);
        avoidForce.add(away);
      }
    }
    if (avoidForce.magSq() > 0) {
      avoidForce.normalize().mult(fish.speed);
    }
    return avoidForce;
  }

  Food findNearestFood() {
    if (foodList == null || foodList.isEmpty()) return null;
    float foodRadius = 300;
    Food nearest = null;
    float minDist = Float.MAX_VALUE;
    for (Food f : foodList) {
      float d = PVector.dist(fish.position, f.position);
      if (d < minDist && d < foodRadius) {
        minDist = d;
        nearest = f;
      }
    }
    return nearest;
  }
}
