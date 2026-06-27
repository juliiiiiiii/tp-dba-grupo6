package ar.edu.unlam.parques;

import io.javalin.Javalin;
import io.javalin.rendering.template.JavalinVelocity;
import org.junit.jupiter.api.Test;

class JavalinStartupTest {
    @Test
    void startsServer() {
        Javalin app = Javalin.create(config -> {
            config.staticFiles.add("/public");
            config.fileRenderer(new JavalinVelocity());
        });
        app.start(0);
        app.stop();
    }
}
