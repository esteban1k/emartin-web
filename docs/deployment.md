# Despliegue y checks en GitHub

## Modelo

| Aspecto | Valor |
| --- | --- |
| Hosting | **GitHub Pages** (`main`, raíz del repo) |
| Dominio | `emartin.com.ar` (`CNAME`) |
| CI en repo | `.github/workflows/` → **CI**, **Police Preflight**, **Police Docs** |

No hay Worker de Cloudflare, `wrangler.toml` ni build de Workers en este repositorio. El sitio es HTML estático (patrón `proyecto-orden-web`).

## Checks esperados (del repo)

En PR y push con PR abierto:

| Check | Origen |
| --- | --- |
| **Static site** / **CI** | `ci.yml` |
| **Police Preflight** | `police-preflight.yml` |
| **Police Docs** | `police-docs.yml` |

Tras merge a `main`, GitHub Pages puede mostrar **build** / **deploy** / **report-build-status** (normales).

## Check ajeno: *Workers Builds: emartin-web*

Si aparece en rojo con:

> Preview creation failed: This Worker does not exist on your account.

**No** lo genera este repo. Lo publica la GitHub App [**Cloudflare Workers and Pages**](https://github.com/apps/cloudflare-workers-and-pages) porque el repo quedó vinculado a un Worker llamado `emartin-web` que no existe (o fue borrado) en la cuenta Cloudflare.

Referencia del fallo típico: app `cloudflare-workers-and-pages`, check `Workers Builds: emartin-web`.

### Opción A — Quitar el repo de la app (recomendado)

1. https://github.com/esteban1k/emartin-web → **Settings**
2. **Integrations** → **Applications** (o **Installed GitHub Apps**)
3. **Cloudflare Workers and Pages** → **Configure**
4. En **Repository access**, quitar **emartin-web** (o desinstalar la app si no la usás para otros repos)
5. Guardar

### Opción B — Desvincular en Cloudflare

1. https://dash.cloudflare.com → **Workers & Pages**
2. Abrir el servicio Worker **emartin-web** (si figura) o **Builds** / integración Git
3. Desconectar el repositorio **esteban1k/emartin-web**, o eliminar el proyecto Worker si era un intento abandonado

### Opción C — Crear el Worker (solo si querés Workers aquí)

No aplica al sitio actual (Pages). Solo si decidís migrar el hosting a Cloudflare Workers/Pages con código Worker real.

### Verificación

1. Hacé un push vacío o **Re-run all checks** en el último commit de una rama de prueba
2. El rollup no debería incluir **Workers Builds: emartin-web**
3. Los tres workflows del repo siguen en verde

### No confundir

- **pages-build-deployment** / jobs de **GitHub Pages** → dejarlos; son el deploy correcto.
- **Workers Builds** → Cloudflare; quitar si el sitio sigue en GitHub Pages.