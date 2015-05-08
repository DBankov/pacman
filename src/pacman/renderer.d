module pacman.renderer;

import std.experimental.logger;
import std.file;
import std.string;

import gfm.opengl;

import pacman;
import pacman.globals;

struct Vertex
{
    vec2f coordinate;
    vec2f textureCoordinate;
}

class Renderer
{
    private GLProgram _program;
    private GLBuffer buffer;
    private VertexSpecification!Vertex specification;
    private GLTexture2D texture;
    private mat4 view;
    private mat4 projection;
    
    this()
    {
        {
            auto vertexShaderSource = read_lines("res/shader.vs");
            auto fragmentShaderSource = read_lines("res/shader.fs");
            
            info("vertex shader source: ", vertexShaderSource);
            info("fragment shader source: ", fragmentShaderSource);
            
            auto vertexShader = new GLShader(opengl, GL_VERTEX_SHADER, vertexShaderSource); scope(exit) vertexShader.close;
            auto fragmentShader = new GLShader(opengl, GL_FRAGMENT_SHADER, fragmentShaderSource); scope(exit) fragmentShader.close;
            _program = new GLProgram(opengl, [vertexShader, fragmentShader]);
            
            _program.link;
            _program.use;
        }
        
        {
            enum float vertexMin = 0;
            enum float vertexMax = 1;
            enum float uvMin = 0;
            enum float uvMax = 1;
            
            immutable shape = [
                Vertex(
                    vec2f(vertexMin, vertexMax),
                    vec2f(uvMin, uvMax)
                ),
                Vertex(
                    vec2f(vertexMax, vertexMax),
                    vec2f(uvMax, uvMax)
                ),
                Vertex(
                    vec2f(vertexMax, vertexMin),
                    vec2f(uvMax, uvMin)
                ),
                Vertex(
                    vec2f(vertexMin, vertexMax),
                    vec2f(uvMin, uvMax)
                ),
                Vertex(
                    vec2f(vertexMax, vertexMin),
                    vec2f(uvMax, uvMin)
                ),
                Vertex(
                    vec2f(vertexMin, vertexMin),
                    vec2f(uvMin, uvMin)
                ),
            ];
            buffer = new GLBuffer(opengl, GL_ARRAY_BUFFER, GL_STATIC_DRAW, shape.dup);
            specification = new VertexSpecification!Vertex(_program);
            
            buffer.bind;
            specification.use;
        }
        
        auto textureSource = sdlImage.load("res/missing.png"); scope(exit) textureSource.close;
        texture = new GLTexture2D(opengl);
        
        texture.setMinFilter(GL_LINEAR_MIPMAP_LINEAR);
        texture.setMagFilter(GL_LINEAR);
        texture.setWrapS(GL_REPEAT);
        texture.setWrapT(GL_REPEAT);
        texture.setImage(0, GL_RGBA, textureSource.width, textureSource.height, 0, GL_BGRA, GL_UNSIGNED_BYTE, textureSource.pixels);
        texture.generateMipmap();
        
        projection = mat4.orthographic(
            0, WIDTH,
            0, HEIGHT,
            0.0, 5.0,
        );
        view = mat4.lookAt(
            vec3f(0.0, 0.0, 1.0),
            vec3f(0.0, 0.0, 0.0),
            vec3f(0.0, 1.0, 0.0),
        );
        
        _program.uniform("projection").set(projection);
        _program.uniform("view").set(view);
    }
    
    @property GLProgram program()
    {
        return _program;
    }
    
    void close()
    {
        _program.close;
        buffer.close;
        texture.close;
    }
    
    void draw()
    {
        glDrawArrays(GL_TRIANGLES, 0, cast(int)(buffer.size / specification.vertexSize));
    }
}

private string[] read_lines(string filename)
{
    return filename.readText.split("\n");
}