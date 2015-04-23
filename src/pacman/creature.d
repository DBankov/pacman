module pacman.creature;

import std.math;

import pacman;
import pacman.globals;

class Creature
{
    
    vec2i gridPosition = vec2i(0, 0);
    vec2 screenPosition = vec2(0, 0);
    vec2i wantedVelocity = vec2i(0, 0); //velocity for next movement action
    vec2i velocity = vec2i(0, 0); //current movement velocity
    
    real speed = TILE_SIZE * 3.5; //speed of movement, in tiles per second
    bool startMoving = false; //whether to begin movement
    bool moving = false; //whether movement is currently happening
    
    void set_position(vec2i gridPosition)
    {
        this.gridPosition = gridPosition;
        this.screenPosition = vec2(
            gridPosition.x * TILE_SIZE,
            gridPosition.y * TILE_SIZE
        );
    }
    
    void update_position()
    {
        if(!should_move)
            return;
        
        immutable newScreenPosition = (gridPosition + velocity) * TILE_SIZE;
        immutable diff = screenPosition - newScreenPosition;
        immutable absDiff = vec2(diff.x.abs, diff.y.abs);
        immutable epsilon = TILE_SIZE;
        
        if(absDiff.x <= epsilon && absDiff.y <= epsilon)
        {
            moving = false;
            screenPosition = gridPosition * TILE_SIZE;
            
            done_moving;
            
            return;
        }
        
        screenPosition += cast(vec2)velocity * speed * timeDelta;
    }
    
    bool should_move()
    {
        if(!moving && !startMoving)
            return false;
        
        if(!moving && startMoving)
        {
            startMoving = false;
            immutable newPosition = gridPosition + wantedVelocity;
            
            if(!valid_position(newPosition))
                return false;
            
            velocity = wantedVelocity;
            gridPosition += velocity;
            moving = true;
            
            begin_moving;
        }
        
        return true;
    }
    
    bool valid_position(vec2i newPosition)
    {
        if(newPosition.x < 0 || newPosition.x >= grid.size.x ||
           newPosition.y < 0 || newPosition.y >= grid.size.y)
            return false;
        
        if(grid.solid(newPosition))
            return false;
        
        immutable dx = vec2i(wantedVelocity.x, 0);
        immutable dy = vec2i(0, wantedVelocity.y);
        
        if(grid.solid(gridPosition + dx) && grid.solid(gridPosition + dy))
            return false;
        
        return true;
    }
    
    void update_velocity() {}
    void begin_moving() {}
    void done_moving() {}
    void render() {}
    
    void update()
    {
        update_velocity;
        update_position;
    }
}