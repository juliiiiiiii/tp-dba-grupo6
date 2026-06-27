package ar.edu.unlam.parques.model;

public record ParqueItem(
        int id,
        String nombre,
        String tipo,
        String ubicacion,
        int superficie
) {
}
