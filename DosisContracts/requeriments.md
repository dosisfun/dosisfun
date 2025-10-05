# Especificación del Juego - DOSIS.FUN

## Concepto General
DOSIS.FUN es un juego blockchain donde los jugadores coleccionan NFTs que representan personajes, crean y comercian drogas virtuales, y compiten en un leaderboard por reputación. El juego combina mecánicas de crafting, trading y economía con dos monedas: Cash (in-game) y $DOSIS (token).

---

## Sistema de Personajes (NFTs)

### Atributos del Personaje
Cada NFT representa un personaje único con las siguientes estadísticas:

- **Reputación**: Puntos acumulados que determinan posición en el leaderboard
- **Cash**: Moneda in-game para comprar ingredientes y drogas de otros jugadores
- **Nivel**: Se calcula automáticamente basado en la experiencia
- **Experiencia (XP)**: Puntos que se ganan al vender drogas y realizar acciones
- **Drogas Creadas**: Historial/contador de drogas que el jugador ha fabricado
- **Inventario de Drogas**: Lista de drogas que posee, puede tener múltiples unidades de la misma droga
- **Inventario de Ingredientes**: Lista de ingredientes que posee, puede tener múltiples unidades del mismo ingrediente

### Notas de Implementación
- Un usuario puede tener múltiples NFTs (personajes)
- Cada personaje es independiente con sus propios inventarios y estadísticas
- Las estadísticas deben persistir en el contrato asociado al NFT

---

## Sistema de Drogas

### Atributos de una Droga
Cada droga en el juego tiene:

- **Nombre**: Definido por el usuario al crearla
- **Rareza**: 5 niveles
  - Base (más común)
  - Common
  - Rare
  - Ultra Rare
  - Legendary (más rara)
- **Reputación al Vender**: Cantidad de puntos de reputación que otorga cuando se vende
- **Cash al Vender**: Cantidad de Cash que genera cuando se vende

### Mecánica de Creación de Drogas

1. **Drogas Base**: El jugador compra ingredientes con Cash y los usa para crear drogas base
2. **Combinación**: El jugador puede comprar drogas de otros usuarios y combinarlas para crear nuevas drogas
3. **Sistema de Rareza**: La calidad de las drogas usadas en la combinación determina la rareza de la droga resultante
   - Mejores ingredientes/drogas = mayor probabilidad de rareza alta
   - Ingredientes/drogas de baja calidad = probablemente resultarán en rareza baja

### Notas de Implementación
- La lógica de determinación de rareza debe ser un algoritmo que considere la calidad de los inputs
- Las imágenes se generan mediante integración con API de IA (fuera del contrato)
- Los valores de reputación y cash por rareza deben ser configurables

---

## Sistema de Comercio

### Mercado Negro (Marketplace)

El mercado negro es donde los jugadores listan y compran drogas usando $DOSIS (token del juego).

#### Listar una Droga en el Mercado
- **Costo de Listing**: 1000 $DOSIS
- **Distribución del Fee**:
  - 40% → Contrato del Leaderboard (para premios de temporada)
  - 60% → Wallet del Team

#### Comprar una Droga en el Mercado
- **Precio Determinado por Rareza**:
  - Base: 50 $DOSIS (mínimo)
  - Common: 100 $DOSIS
  - Rare: 200 $DOSIS
  - Ultra Rare: 350 $DOSIS
  - Legendary: 500 $DOSIS (máximo)

- **Distribución del Pago**:
  - 20% → Wallet del vendedor (el usuario que listó)
  - 30% → Contrato del Leaderboard (para premios de temporada)
  - 50% → Wallet del Team

#### Al Completar la Compra
Cuando un usuario compra una droga:
1. La droga se transfiere al inventario del comprador
2. El vendedor recibe automáticamente:
   - Los puntos de **Reputación** que otorga esa droga
   - El **Cash** que otorga esa droga
3. El $DOSIS se distribuye según el esquema de porcentajes

### Compra de Ingredientes
- Los ingredientes se compran con **Cash** (moneda in-game)
- No se usa $DOSIS para ingredientes
- Los ingredientes se agregan al inventario del personaje

---

## Sistema de Leaderboard y Temporadas

### Mecánica del Leaderboard
- Los jugadores compiten por **Reputación**
- El leaderboard rankea a todos los jugadores por sus puntos de reputación
- Es global (no por personaje individual)

### Sistema de Temporadas
- Las temporadas tienen duración definida (ej: 1 mes, 3 meses)
- Al final de cada temporada:
  - Se distribuyen los fondos acumulados en el **Contrato del Leaderboard**
  - Los premios se reparten entre los top jugadores según ranking
  - El leaderboard puede resetearse o continuar acumulando

### Distribución de Premios
Los fondos del Contrato del Leaderboard provienen de:
- 40% de cada listing fee (1000 $DOSIS por listing)
- 30% de cada compra en el mercado negro

Estos fondos se distribuyen proporcionalmente entre los mejores jugadores del leaderboard al finalizar la temporada.

---

## Flujos de Usuario Principales

### Flujo 1: Crear Drogas Base
1. Usuario compra ingredientes con Cash
2. Usuario usa ingredientes para craftear una droga base
3. Sistema genera imagen con IA
4. Usuario nombra su droga
5. Droga se agrega al inventario con rareza "Base"

### Flujo 2: Combinar Drogas
1. Usuario compra drogas de otros jugadores en el mercado negro (con $DOSIS)
2. Usuario selecciona drogas de su inventario para combinar
3. Sistema calcula rareza de la nueva droga basado en inputs
4. Sistema genera nueva imagen con IA
5. Usuario nombra la nueva droga
6. Nueva droga se agrega al inventario

### Flujo 3: Vender en el Mercado Negro
1. Usuario paga 1000 $DOSIS para listar
2. Usuario selecciona droga de su inventario
3. Sistema calcula precio automáticamente según rareza
4. Droga aparece en el marketplace
5. Cuando alguien compra:
   - Comprador recibe la droga
   - Vendedor recibe reputación + cash de la droga
   - $DOSIS se distribuye según porcentajes

### Flujo 4: Ganar Reputación
El usuario gana reputación:
- Cuando vende una droga en el mercado negro
- La cantidad depende del atributo "reputación" de cada droga

---

## Economía del Juego

### Dos Monedas

1. **Cash (In-Game)**
   - Se gana vendiendo drogas en el mercado
   - Se usa para comprar ingredientes
   - No sale del ecosistema del juego
   - Vinculado a cada personaje

2. **$DOSIS (Token Blockchain)**
   - Token real con valor
   - Se usa para comprar drogas en el mercado negro
   - Se usa para pagar listing fees
   - Se distribuye entre team y pool de premios

### Consideraciones de Balance
- Los precios de ingredientes deben estar balanceados con el Cash que generan las drogas
- Los precios en $DOSIS deben incentivar el trading activo
- El fee de listing (1000 $DOSIS) debe ser significativo pero no prohibitivo
- La distribución de $DOSIS debe mantener liquidez en el pool de premios

---

## Requerimientos Técnicos Clave

### Contratos Inteligentes Necesarios
1. **NFT Contract**: Minteo de personajes
2. **Character Manager**: Gestión de estadísticas y atributos de personajes
3. **Drug Registry**: Registro de todas las drogas creadas
4. **Marketplace Contract**: Lógica de compra/venta con $DOSIS
5. **Leaderboard Contract**: Acumulación y distribución de premios
6. **Ingredient Shop**: Venta de ingredientes por Cash

### Integraciones Externas
- Oracle para rareza/randomness (si se usa)
- Sistema de temporadas (puede ser off-chain con checkpoints on-chain)

### Datos a Almacenar On-Chain
- Atributos de personajes
- Inventarios (drogas e ingredientes)
- Registry de drogas creadas
- Listings activos en el marketplace
- Historial de transacciones importantes
- Rankings del leaderboard

### Datos que Pueden Ser Off-Chain
- Imágenes de drogas (IPFS o storage tradicional)
- Historial completo de transacciones (indexado)
- Metadatos extensos de drogas
- UI/UX del juego

---

## Consideraciones de Producto

### Engagement del Usuario
- Sistema de progresión clara (XP → Nivel)
- Recompensas por experimentación (crear nuevas drogas)
- Competencia social (leaderboard)
- Economía circular (trading beneficia a ambas partes)

### Monetización
- 50% de cada compra en marketplace va al team
- 60% de cada listing fee va al team
- Incentivo para holdear y jugar ($DOSIS tiene utilidad)

### Retención
- Temporadas crean ciclos de engagement
- Premios del leaderboard incentivan juego activo
- Colección de drogas raras (aspecto coleccionable)
- Economía de crafting profunda (múltiples combinaciones)
