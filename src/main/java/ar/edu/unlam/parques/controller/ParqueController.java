package ar.edu.unlam.parques.controller;

import ar.edu.unlam.parques.model.ParqueForm;
import ar.edu.unlam.parques.model.ParqueItem;
import ar.edu.unlam.parques.model.UbicacionItem;
import ar.edu.unlam.parques.service.ParqueService;
import io.javalin.Javalin;
import io.javalin.http.Context;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ParqueController {
    private final ParqueService parqueService;

    public ParqueController(ParqueService parqueService) {
        this.parqueService = parqueService;
    }

    public void register(Javalin app) {
        app.get("/parques/alta", this::mostrarAlta);
        app.post("/parques/alta", this::alta);

        app.get("/parques/baja", this::mostrarBaja);
        app.post("/parques/baja", this::baja);

        app.get("/parques/modificacion", this::mostrarModificacion);
        app.post("/parques/modificacion", this::modificacion);
    }

    private void alta(Context ctx) {
        try {
            ParqueForm form = ParqueForm.fromAlta(ctx);
            parqueService.alta(form);
            renderAlta(ctx, "Parque creado correctamente.", null);
        } catch (Exception e) {
            renderAlta(ctx, null, readableMessage(e));
        }
    }

    private void baja(Context ctx) {
        try {
            int id = parseInt(ctx.formParam("id"), "id");
            parqueService.baja(id);
            renderBaja(ctx, "Parque dado de baja correctamente.", null);
        } catch (Exception e) {
            renderBaja(ctx, null, readableMessage(e));
        }
    }

    private void modificacion(Context ctx) {
        try {
            ParqueForm form = ParqueForm.fromModificacion(ctx);
            parqueService.modificar(form);
            renderModificacion(ctx, "Parque modificado correctamente.", null);
        } catch (Exception e) {
            renderModificacion(ctx, null, readableMessage(e));
        }
    }

    private void mostrarAlta(Context ctx) {
        renderAlta(ctx, null, null);
    }

    private void mostrarBaja(Context ctx) {
        renderBaja(ctx, null, null);
    }

    private void mostrarModificacion(Context ctx) {
        renderModificacion(ctx, null, null);
    }

    private void renderAlta(Context ctx, String success, String error) {
        Map<String, Object> model = baseModel("Alta de parque", success, error);
        try {
            model.put("ubicaciones", parqueService.listarUbicaciones());
        } catch (Exception e) {
            model.put("ubicaciones", List.of());
            model.put("error", readableMessage(e));
        }
        ctx.render("templates/parques/alta.vm", model);
    }

    private void renderBaja(Context ctx, String success, String error) {
        Map<String, Object> model = baseModel("Baja de parque", success, error);
        try {
            model.put("parques", parqueService.listarActivos());
        } catch (Exception e) {
            model.put("parques", List.of());
            model.put("error", readableMessage(e));
        }
        ctx.render("templates/parques/baja.vm", model);
    }

    private void renderModificacion(Context ctx, String success, String error) {
        Map<String, Object> model = baseModel("Modificacion de parque", success, error);
        try {
            List<ParqueItem> parques = parqueService.listarActivos();
            List<UbicacionItem> ubicaciones = parqueService.listarUbicaciones();
            model.put("parques", parques);
            model.put("ubicaciones", ubicaciones);
        } catch (Exception e) {
            model.put("parques", List.of());
            model.put("ubicaciones", List.of());
            model.put("error", readableMessage(e));
        }
        ctx.render("templates/parques/modificacion.vm", model);
    }

    private Map<String, Object> baseModel(String title, String success, String error) {
        Map<String, Object> model = new HashMap<>();
        model.put("title", title);
        model.put("success", success);
        model.put("error", error);
        return model;
    }

    private int parseInt(String value, String fieldName) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("El campo " + fieldName + " es obligatorio.");
        }
        return Integer.parseInt(value);
    }

    private String readableMessage(Exception e) {
        Throwable current = e;
        while (current != null) {
            if (current instanceof SQLException && current.getMessage() != null) {
                return current.getMessage();
            }
            current = current.getCause();
        }
        return e.getMessage();
    }
}
