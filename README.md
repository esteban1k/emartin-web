# emartin-web

Sitio estático personal (GitHub Pages cuando publiques). **Repo privado** — WIP.

<!-- Dominio previsto en producción: emartin.com.ar (CNAME en repo; sin deploy Pages hasta que Esteban lo pida). -->

## Ejes

| Ruta | Tema |
| --- | --- |
| `/` | Hub |
| `/cocina/` | Cocinero |
| `/qa/` | QA |
| `/dev/` | Desarrollador |
| `/neuro/` | Neurodivergente |

## Local

```bash
./tool/serve.sh
```

Abre http://127.0.0.1:8765

## CI (GitHub Actions)

En PR: **CI** (`static_check` + `CNAME`). En push a ramas de trabajo con PR abierto: **Police Preflight** y **Police Docs** (perfil web, como `proyecto-orden-web`).

## GitHub Pages (futuro)

Mismo patrón que `proyecto-orden-web`: rama `main`, `.nojekyll`, carpeta raíz o `docs/` según settings.

## Marca

Ver [`docs/brand-palette.md`](docs/brand-palette.md). Afinar con *Guía de Marca* (Drive).
