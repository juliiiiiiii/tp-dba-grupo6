package ar.edu.unlam.parques;

import ar.edu.unlam.parques.controller.ParqueController;
import ar.edu.unlam.parques.db.LazyDataSource;
import ar.edu.unlam.parques.repository.ParqueRepository;
import ar.edu.unlam.parques.repository.UbicacionRepository;
import ar.edu.unlam.parques.service.ParqueService;
import io.javalin.Javalin;
import io.javalin.rendering.template.JavalinVelocity;

public class App {
    public static void main(String[] args) {
        LazyDataSource dataSource = new LazyDataSource();
        ParqueRepository parqueRepository = new ParqueRepository(dataSource);
        UbicacionRepository ubicacionRepository = new UbicacionRepository(dataSource);
        ParqueService parqueService = new ParqueService(parqueRepository, ubicacionRepository);
        ParqueController parqueController = new ParqueController(parqueService);

        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "7000"));

        Javalin app = Javalin.create(config -> {
            config.staticFiles.add("/public");
            config.fileRenderer(new JavalinVelocity());
        });

        app.get("/", ctx -> ctx.redirect("/parques/alta"));
        parqueController.register(app);

        app.events(event -> event.serverStopped(dataSource::close));
        app.start(port);
    }
}
