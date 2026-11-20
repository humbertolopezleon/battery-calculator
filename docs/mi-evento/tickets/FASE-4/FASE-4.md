# FASE-4 — Integración entre la APK y la web

> **Fuente:** `docs/mi-evento/PLAN.md` §3 (formato de exportación), §8 (integración), §9, §12
> **Estimación:** 4–6 semanas
> **Depende de:** FASE-1 (formato y columnas base); se recomienda FASE-3 terminada
> **Bloquea a:** nada

## Objetivo

Permitir que un evento pase de un dispositivo a otro (APK ↔ app de Windows) sin perder ni duplicar datos, aprovechando desde ya los identificadores, marcas de tiempo y el formato de exportación que se definieron en FASE-0 y FASE-1. Hoy un solo dispositivo escribe por evento; esta fase no cambia esa regla de uso, solo hace seguro el traspaso y la fusión.

## Alcance

### Traspaso y fusión de eventos

- «Exportar paquete» genera un `.mievento.json` con checksum y los metadatos de propiedad (`owner_device_id`).
- Al importar:
  - Si el evento no existe en el dispositivo, se crea.
  - Si ya existe, se muestra una **vista previa de diferencias** («N nuevos, N modificados, N conflictos») y el usuario confirma antes de aplicar.
- Resolución por registro: gana el de mayor `rev`, con `updated_at` y `device_id` como desempate. Los conflictos reales (mismo registro cambiado en ambos lados) se listan para revisión manual.
- Los borrados lógicos y las lápidas se fusionan igual que el resto de registros.

### Avisos de seguridad del traspaso

- Al exportar para traspaso, el evento queda marcado como «entregado al dispositivo X». Si alguien sigue editándolo en el origen, la app avisa.
- Aviso al iniciar si la fecha del dispositivo es anterior a la de compilación. La comparación entre dispositivos usa `rev` y no solo la hora.

### `change_log`

- Tabla `change_log` para exportar solo los cambios desde la última vez.

### Opcional en esta fase (decidir al planificar)

- Sincronización por Wi‑Fi local (la PC sirve un pequeño servidor al que se conecta el móvil) o nube opcional, sobre el mismo formato.

## Criterios de aceptación

- [ ] Exportar un evento desde la APK e importarlo en la app de Windows (y al revés) reproduce todos los registros, incluidos matrimonios, grupos, habitaciones, asignaciones, equipos y sesiones de comida.
- [ ] Importar dos veces el mismo paquete no duplica registros.
- [ ] La vista previa de diferencias coincide con lo que realmente se aplica.
- [ ] Un conflicto real (mismo registro modificado en ambos dispositivos) aparece en la lista de revisión y no se resuelve en silencio.
- [ ] Un registro borrado en un dispositivo se borra también en el otro tras la fusión, y no conserva datos personales.
- [ ] Un paquete con checksum alterado se rechaza.
- [ ] Editar un evento ya entregado a otro dispositivo muestra el aviso de propiedad.
- [ ] Un reloj con fecha anterior a la de compilación muestra un aviso y no altera el criterio de resolución por `rev`.

## Fuera de alcance

- Edición concurrente en tiempo real por varios dispositivos.
- Cuentas de usuario o permisos entre dispositivos.

## Decisiones ya tomadas (no reabrir)

- Resolución por registro con `rev`, `updated_at` y `device_id`.
- Los conflictos reales se revisan a mano, no se resuelven en silencio.
- Formato JSON versionado con checksum.

## Riesgos y preguntas abiertas

- Dos dispositivos editando el mismo evento por error: mitigado con marca de propietario, vista previa y resolución por registro.
- Relojes mal configurados en móviles: mitigado comparando por `rev`.
- Decidir al planificar si la sincronización por Wi‑Fi local o en la nube entra en esta fase o se pospone.
