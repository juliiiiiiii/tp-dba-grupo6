package ar.edu.unlam.parques.model;

import io.javalin.http.Context;

public record ParqueForm(
        String nombreId,
        String nombre,
        String tipo,
        String ubicacion,
        int superficie
) {
    public static ParqueForm fromAlta(Context ctx) {
        return new ParqueForm(
                null,
                required(ctx, "nombre"),
                required(ctx, "tipo"),
                required(ctx, "ubicacion"),
                parseInt(required(ctx, "superficie"), "superficie")
        );
    }

    public static ParqueForm fromModificacion(Context ctx) {
        return new ParqueForm(
                required(ctx, "id"),
                required(ctx, "nombre"),
                required(ctx, "tipo"),
                required(ctx, "ubicacion"),
                parseInt(required(ctx, "superficie"), "superficie")
        );
    }

    private static String required(Context ctx, String name) {
        String value = ctx.formParam(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("El campo " + name + " es obligatorio.");
        }
        return value.trim();
    }

    private static int parseInt(String value, String name) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("El campo " + name + " debe ser numerico.");
        }
    }
}
