Button Btn;
ArrayList<Enemy> Enemies;
int EnemyCount;
int EnemyKilled;
Boolean IsGameRunning;
PVector InitialControllerLocation;
PVector ControllerLocation;
PVector Direction;
PVector InitialShooterLocation;
PVector ShooterLocation;
PVector ShooterDirection;
float ControllerRadius;
float ShooterRadius;

void setup()
{
    frameRate(60);
    fullScreen();
    orientation(LANDSCAPE);
    
    Btn = new Button();
    
    // Initialise enemies:
    EnemyKilled = 0;
    EnemyCount =0;
    Enemies = new ArrayList<Enemy>();
    for(int i = 0; i < EnemyCount; i++)
    {
        Enemies.add(new Enemy());
    }
    
    // Configure Controller:
    ControllerRadius = width/8;
    InitialControllerLocation = new PVector(ControllerRadius + 50, height - (ControllerRadius + 50));
    ControllerLocation = new PVector(width/4, height - (height/5));
    Direction = new PVector(0, 0);
    
    // Configure Shooter:
    ShooterRadius = width/8;
    InitialShooterLocation = new PVector(width - (ShooterRadius + 50), height - (ShooterRadius + 50));
    ShooterLocation = new PVector(width - (ShooterRadius + 50), height - (ShooterRadius + 50));
    ShooterDirection = new PVector(0, -1);
    
    IsGameRunning = true;
}

void draw()
{
    if (IsGameRunning)
    {
        background(120, 20, 230);
        
        drawController();
        drawShooter();
        
        Btn.applyForce(PVector.mult(Direction, 5));
        Btn.aim(ShooterDirection);
        Btn.Update();
        Btn.Display();
        Btn.DrawHealthBar();
        Btn.checkBounds();

        for(Enemy e : Enemies)
        {
            PVector attractEnemyForce = new PVector(
                Btn.location.x - e.location.x, 
                Btn.location.y - e.location.y
            );
            e.aimButton(attractEnemyForce);
            
            e.Update();
            e.Display();
            
            // Check bullet-enemy interaction
            for(int i = 0; i < Btn.Bullets.size(); i++)
            {
                if(e.CheckIncomingBullet(Btn.Bullets.get(i)))
                {
                    Btn.Bullets.remove(i);
                }
            }
            
            // Check if bullet hits button
            if(Btn.CheckHealth(e))
            {
                e.Replace();
            }
        }
        
        // Check if bullets are off map
        for(int i = 0; i < Btn.Bullets.size(); i++)
        {
            if(Btn.Bullets.get(i).IsOffMap())
            {
                Btn.Bullets.remove(i);
            }
        }
        
        // Check if game must end
        if ((Btn.radius <= 0 && Btn.Bullets.size() == 0) || Btn.health <= 0)
        {
            GameOver();
        }
    }
}

void useShooter()
{
    for (int i = 0; i < touches.length; i++)
    {
        if (touches[i].x > width/2)
        {
            PVector touchVector = new PVector(touches[i].x, touches[i].y);
            ShooterDirection = PVector.sub(touchVector, InitialShooterLocation);
            if(ShooterDirection.mag() > ShooterRadius*1.2 && frameCount % 10 == 0)
            {
                Btn.Fire();
            }
            ShooterDirection.limit(ShooterRadius/2);
            ShooterLocation = PVector.add(InitialShooterLocation, ShooterDirection);
        }
    }
}

void drawShooter()
{
    noFill();
    stroke(255, 100);
    strokeWeight(15);
    ellipseMode(CENTER);
    ellipse(InitialShooterLocation.x, InitialShooterLocation.y, ShooterRadius, ShooterRadius);
    stroke(40);
    line(
        InitialShooterLocation.x, 
        InitialShooterLocation.y, 
        InitialShooterLocation.x + ShooterDirection.x,
        InitialShooterLocation.y + ShooterDirection.y
    );
}

void useController()
{
    for (int i = 0; i < touches.length; i++)
    {
        if (touches[i].x < width/2)
        {
            PVector touchVector = new PVector(touches[i].x, touches[i].y);
            Direction = PVector.sub(touchVector, InitialControllerLocation);
            Direction.limit(ControllerRadius);
            ControllerLocation = PVector.add(InitialControllerLocation, Direction);
        }
    }
}

// Controller:
void drawController()
{
    fill(255, 100);
    strokeWeight(0);
    ellipseMode(CENTER);
    ellipse(InitialControllerLocation.x, InitialControllerLocation.y, ControllerRadius, ControllerRadius);
    fill(40);
    ellipse(
        InitialControllerLocation.x + Direction.x, 
        InitialControllerLocation.y + Direction.y, 
        width/12, 
        width/12
    );
}

void mousePressed()
{
}

void touchEnded()
{
    ControllerLocation = InitialControllerLocation.copy();
    Direction = new PVector(0, 0);
}

void mouseDragged()
{
    for (int i = 0; i < touches.length; i++) {
        if (touches[i].x < width/2)
        {
            useController();
        }
        else
        {
            useShooter();
        }
    }
}

void DrawHelp()
{
    // Help:
    textSize(25);
    fill(255, 160);
    text("Reload game: 'r'", width/4, height - 50);
    text("Control enemy count: (+/-)", width/4, height - 20);
}

void DrawStats()
{
    // STATS:
    textSize(25);
    fill(255, 160);
    text("Ammo: " + Btn.ammo, width/2 + 100, height - 20);
    text("Killed: " + EnemyKilled, width/2 + 250, height - 20);
}

void GameOver()
{
    fill(255, 0, 0);
    textSize(100);
    text("Game Over!", width/4, height/2);
    IsGameRunning = false;
}

void ResetGame()
{
    EnemyCount = 3;
    Btn = new Button();
    Enemies = new ArrayList<Enemy>();
    frameRate(60);
    for(int i = 0; i < EnemyCount; i++)
    {
        Enemies.add(new Enemy());
    }
    IsGameRunning = true;
    EnemyKilled = 0;
}

void keyPressed()
{
    switch(key)
    {
        case 'r':
            ResetGame();
            break;
        case '+':
            Enemies.add(new Enemy());
            Btn.ammo += 5;
            break;
        case '-':
            if(Enemies.size() > 0)
                Enemies.remove(Enemies.size() - 1);
            Btn.ammo -=5;
            break;
        case ' ':
            Btn.Fire();
            break;
    }
}
