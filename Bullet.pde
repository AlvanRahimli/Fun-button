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
    
    void Display()
    {
        fill(252, 255, 50);
        noStroke();
        ellipse(location.x, location.y, radius, radius);
    }
    
    void Update()
    {
        location.add(velocity);
    }
    
    Boolean IsOffMap()
    {
        if (location.x > width || location.y > height || location.x < 0 || location.y < 0)
        {
            return true;
        }
        return false;
    }
}
