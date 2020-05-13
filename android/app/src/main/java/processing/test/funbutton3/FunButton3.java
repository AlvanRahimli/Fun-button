package processing.test.funbutton3;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class FunButton3 extends PApplet {

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

public void setup()
{
    EnemyCount = 0;
    //size(1000, 900);
    
    Btn = new Button();
    Enemies = new ArrayList<Enemy>();
    for(int i = 0; i < EnemyCount; i++)
    {
        Enemies.add(new Enemy());
    }
    EnemyKilled = 0;
    IsGameRunning = true;
    
    InitialControllerLocation = new PVector(width/4, height - (height/5));
    ControllerLocation = new PVector(width/4, height - (height/5));
    Direction = new PVector(0, 0);
    
    InitialShooterLocation = new PVector(width - width/4, height - (height/5));
    ShooterLocation = new PVector(width - width/4, height - (height/5));
    ShooterDirection = new PVector(0, -1);
}

public void draw()
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
        
        // Check button radius
        if (Btn.radius <= 0 || Btn.health <= 0)
        {
            GameOver();
        }
    }
}

public void useShooter()
{
    for (int i = 0; i < touches.length; i++)
    {
        if (touches[i].x > width/2)
        {
            PVector touchVector = new PVector(touches[i].x, touches[i].y);
            ShooterDirection = PVector.sub(touchVector, InitialShooterLocation);
            if(ShooterDirection.mag() > width/5 && Btn.canFire)
            {
                Btn.Fire();
                Btn.canFire = false;
            }
            ShooterDirection.limit(width/6);
            ShooterLocation.x = InitialShooterLocation.x + ShooterDirection.x;
            ShooterLocation.y = InitialShooterLocation.y + ShooterDirection.y;
        }
    }
}

public void drawShooter()
{
    noFill();
    stroke(255, 200);
    strokeWeight(15);
    ellipseMode(CENTER);
    ellipse(width - width/4, height - (height/5), width/3, width/3);
    stroke(40);
    line(
        InitialShooterLocation.x, 
        InitialShooterLocation.y, 
        InitialShooterLocation.x + ShooterDirection.x,
        InitialShooterLocation.y + ShooterDirection.y
    );
}

public void useController()
{
    for (int i = 0; i < touches.length; i++)
    {
        if (touches[i].x < width/2)
        {
            PVector touchVector = new PVector(touches[i].x, touches[i].y);
            Direction = PVector.sub(touchVector, InitialControllerLocation);
            Direction.limit(width/12);
            ControllerLocation.x = InitialControllerLocation.x + Direction.x;
            ControllerLocation.y = InitialControllerLocation.y + Direction.y;
        }
    }
}

// Controller:
public void drawController()
{
    fill(255, 200);
    strokeWeight(0);
    ellipseMode(CENTER);
    ellipse(width/4, height - (height/5), width/3, width/3);
    fill(40);
    ellipse(
        InitialControllerLocation.x + Direction.x, 
        InitialControllerLocation.y + Direction.y, 
        width/12, 
        width/12
    );
}

public void mousePressed()
{
}

public void touchEnded()
{
    Btn.canFire = true;
    ControllerLocation = InitialControllerLocation.copy();
    Direction = new PVector(0, 0);
}

public void mouseDragged()
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

public void DrawHelp()
{
    // Help:
    textSize(25);
    fill(255, 160);
    text("Reload game: 'r'", width/4, height - 50);
    text("Control enemy count: (+/-)", width/4, height - 20);
}

public void DrawStats()
{
    // STATS:
    textSize(25);
    fill(255, 160);
    text("Ammo: " + Btn.ammo, width/2 + 100, height - 20);
    text("Killed: " + EnemyKilled, width/2 + 250, height - 20);
}

public void GameOver()
{
    fill(255, 0, 0);
    textSize(100);
    text("Game Over!", width/4, height/2);
    IsGameRunning = false;
}

public void ResetGame()
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

public void keyPressed()
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
class Bullet
{
    PVector location;
    PVector velocity;
    float radius;
    int mass;
    
    Bullet(PVector loc, PVector vel, float rad)
    {
        location = loc;
        velocity = vel;
        radius = rad;
    }
    
    public void Display()
    {
        fill(252, 255, 50);
        noStroke();
        ellipse(location.x, location.y, radius, radius);
    }
    
    public void Update()
    {
        location.add(velocity);
    }
    
    public Boolean IsOffMap()
    {
        if (location.x > width || location.y > height || location.x < 0 || location.y < 0)
        {
            return true;
        }
        return false;
    }
}
class Button
{
    PVector location;
    PVector velocity;
    PVector acceleration;
    PVector shooterDirection;
    int radius;
    int mass;
    ArrayList<Bullet> Bullets;
    float health;
    int ammo;
    Boolean canFire;
    
    Button()
    {
        location = new PVector(width/2, height/2);
        velocity = new PVector(0, 0);
        acceleration = new PVector(0, 0);
        radius = 70;
        mass = 1000;
        Bullets = new ArrayList<Bullet>();
        health = 10;
        ammo = 100;
        shooterDirection = new PVector(0, -1);
        canFire = true;
    }
    
    public void Display()
    {
        fill(150, 255, 50);
        noStroke();
        ellipse(location.x, location.y, radius, radius);
        
        // Draw PP
        fill(255);
        stroke(150, 255, 50);
        strokeWeight(map(radius, 0, 70, 0, 15));
        float len = map(radius, 0, 70, 0, 40);
        line(location.x, location.y, location.x + shooterDirection.x*len, location.y + shooterDirection.y*len);
        for(Bullet blt : Bullets)
        {
            blt.Update();
            blt.Display();
        }
    }

    public void DrawHealthBar()
    {
        strokeWeight(0);
        // Health bar:
        fill(255, 200);
        textSize(18);
        text("Health:", 20, height - 54);
        fill(0);
        rect(20, height - 50, 208, 30);
        fill(255, 200);
        rect(24, height - 46, Btn.health * 20, 22);
    }

    public void Update()
    {
        velocity.limit(8);
        velocity.add(acceleration);
        location.add(velocity);
    }
    
    public void aim(PVector aim)
    {
        aim.normalize();
        shooterDirection = aim;
    }
    
    public void applyForce(PVector force)
    {
        acceleration.mult(0);
        PVector acc = force.div(mass);
        acceleration.add(acc);
    }
    
    public void Fire()
    {
        if (ammo > 0 && canFire)
        {
            Btn.radius -= 5;
            
            Bullet blt = new Bullet(
                new PVector(location.x + shooterDirection.x * radius, location.y + shooterDirection.y * radius),
                PVector.mult(shooterDirection, 15),
                random(20, 15)
            );
            Bullets.add(blt);
            ammo --;
            
            // apply impact
            velocity.add(PVector.mult(shooterDirection, -1));
        }
    }
    
    public Boolean CheckHealth(Enemy e)
    {
        float d = dist(location.x, location.y, e.location.x, e.location.y);
        if (d < radius)
        {
            health --;
            return true;
        }
        return false;
    }
}
class Enemy
{
    PVector location;
    PVector velocity;
    
    Enemy()
    {
        float x = random(width);
        float y = random(20);
        location = new PVector(x, y);
        velocity = new PVector(0, 0);
    }
    
    public void Display()
    {
        fill(255, 0, 40);
        noStroke();
        rect(location.x, location.y, 20, 20);
    }
    
    public void Update()
    {
        if (location.x > width || location.y > height || location.x < 0 || location.y < 0)
        {
            Replace();
        }
        velocity.limit(5);
        location.add(velocity);
    }
    
    public void aimButton(PVector force)
    {
        force.limit(7);
        velocity = force;
    }
    
    public Boolean CheckIncomingBullet(Bullet b)
    {
        float d = dist(location.x, location.y, b.location.x, b.location.y);
        if (d < b.radius)
        {
            Replace();
            Btn.ammo += 3;
            Btn.radius = 70;
            EnemyKilled ++;
            if (Btn.health <= 9.8f)
                Btn.health += 0.2f;
            return true;
        }
        return false;
    }
    
    public void Replace()
    {
        location.x = random(width);
        location.y = random(20);
    }
}
    public void settings() {  fullScreen(); }
}
