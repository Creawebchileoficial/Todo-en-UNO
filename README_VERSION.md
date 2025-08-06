# Todo Universidad - Sistema de Versiones

## Información de Versión Actual
- **Versión:** 1.2.0
- **Fecha de Build:** 06/08/2025
- **Estado:** Estable

## Scripts de Gestión de Versiones

### 1. `version_info.ps1`
**Descripción:** Muestra información completa sobre la versión actual
**Uso:** `.\version_info.ps1`
**Funciones:**
- Muestra versión actual y fecha de build
- Changelog completo
- Verificación de consistencia entre archivos
- Estadísticas de la aplicación

### 2. `update_version.ps1`
**Descripción:** Actualiza automáticamente el número de versión en todos los archivos
**Uso:** `.\update_version.ps1 -NewVersion "1.3.0" -ReleaseNotes "- Nueva funcionalidad agregada"`
**Archivos que actualiza:**
- index.html (meta tags)
- site.webmanifest (version)
- sw.js (cache names y constantes)
- version_info.ps1 (variable de versión)
- unify_favicon.ps1 (versión del script)
- CHANGELOG.md (nueva entrada)

### 3. `unify_favicon.ps1` (Actualizado)
**Descripción:** Script mejorado con información de versión
**Uso:** `.\unify_favicon.ps1`
**Nuevas características:**
- Muestra versión del script
- Timestamp de build
- Footer con información de versión

## Archivos de Configuración

### index.html
```html
<meta name="version" content="1.2.0">
<meta name="build-date" content="06/08/2025">
<meta name="author" content="Todo Universidad">
```

### site.webmanifest
```json
{
  "version": "1.2.0",
  "version_name": "1.2.0 - Agosto 2025"
}
```

### sw.js
```javascript
const APP_VERSION = '1.2.0';
const CACHE_NAME = `todo-universidad-v${APP_VERSION}`;
```

## Historial de Versiones

### v1.2.0 - 06/08/2025
- ✅ Favicon unificado en todos los archivos HTML
- ✅ PWA completamente funcional
- ✅ Herramientas reorganizadas
- ✅ Lectura.html mejorado con cronómetro
- ✅ Integración con servicios externos (BibGuru, UniTools)
- ✅ Sistema de versiones implementado

### v1.1.0 - 05/08/2025
- ✅ Implementación de PWA
- ✅ Service Worker agregado
- ✅ Soporte para instalación en dispositivos

### v1.0.0 - 01/08/2025
- ✅ Lanzamiento inicial
- ✅ 30+ herramientas académicas
- ✅ Diseño responsive

## Comandos Rápidos

### Verificar versión actual:
```powershell
.\version_info.ps1
```

### Actualizar a nueva versión:
```powershell
.\update_version.ps1 -NewVersion "1.3.0" -ReleaseNotes "- Nuevas características"`
```

### Verificar favicon después de cambios:
```powershell
.\unify_favicon.ps1
```

### Verificación completa:
```powershell
.\verify_complete.ps1
```

## Convenciones de Versionado

**Formato:** MAJOR.MINOR.PATCH

- **MAJOR:** Cambios importantes de arquitectura
- **MINOR:** Nuevas funcionalidades
- **PATCH:** Correcciones de bugs

## Notas Importantes

1. **Siempre actualizar versión antes de deployment**
2. **Mantener CHANGELOG.md actualizado**
3. **Verificar que todos los archivos tengan la misma versión**
4. **Probar PWA después de cambios de versión**

## Estructura de Archivos de Versión

```
todo uni/
├── version_info.ps1          # Info y verificación
├── update_version.ps1        # Actualización automática
├── unify_favicon.ps1         # Favicon con versión
├── verify_complete.ps1       # Verificación completa
├── CHANGELOG.md              # Historial de cambios
├── README_VERSION.md         # Esta documentación
├── index.html                # Meta tags de versión
├── sw.js                     # Version en SW
└── assets/favicon_iotodo/
    └── site.webmanifest      # Version en manifest
```

---
**Todo Universidad v1.2.0**  
*Build: 06/08/2025*
