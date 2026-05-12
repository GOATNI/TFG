#!/bin/bash
# Build and verify PadelMudéjar API

echo "======================================="
echo "PadelMudéjar API - Verification Script"
echo "======================================="
echo ""

# Check Java version
echo "[1/5] Verificando versión de Java..."
java -version 2>&1 | grep -i version

echo ""
echo "[2/5] Verificando estructura de directorios..."
if [ -d "src/main/java/com/padelmudejar/padelMudejarApi" ]; then
    echo "✓ Estructura de paquetes correcta"
    find src/main/java/com/padelmudejar/padelMudejarApi -type d | head -10
else
    echo "✗ Error: Estructura de paquetes incorrecta"
    exit 1
fi

echo ""
echo "[3/5] Contando archivos Java..."
JAVA_COUNT=$(find src -name "*.java" | wc -l)
echo "✓ Total de archivos Java: $JAVA_COUNT"

echo ""
echo "[4/5] Verificando imports correctos..."
IMPORT_ERRORS=$(grep -r "import com\.padelMujedar" src/ 2>/dev/null | wc -l)
if [ $IMPORT_ERRORS -eq 0 ]; then
    echo "✓ No hay imports con paquete incorrecto"
else
    echo "✗ Encontrados $IMPORT_ERRORS imports incorrectos"
    grep -r "import com\.padelMujedar" src/ 2>/dev/null
fi

echo ""
echo "[5/5] Verificando dependencias..."
if [ -f "pom.xml" ]; then
    echo "✓ archivo pom.xml encontrado"
    grep -A1 "<artifactId>spring-boot-starter-web</artifactId>" pom.xml >/dev/null && echo "✓ Spring Web incluido"
    grep -A1 "<artifactId>spring-boot-starter-data-jpa</artifactId>" pom.xml >/dev/null && echo "✓ Spring Data JPA incluido"
    grep "<artifactId>lombok</artifactId>" pom.xml >/dev/null && echo "✓ Lombok incluido"
else
    echo "✗ archivo pom.xml no encontrado"
fi

echo ""
echo "======================================="
echo "Verificación completada ✓"
echo "======================================="

