# Migration vers la nouvelle structure de base de données

Ce document explique la migration de l'application vers la nouvelle structure de base de données définie dans `peche_database.sql`.

## Changements majeurs

1. **Identifiants** : Les identifiants sont maintenant des entiers auto-incrémentés au lieu de chaînes de caractères (UUID).
2. **Noms des tables** : Les tables ont des préfixes comme `marketplace_aommande`, `marketplace_produitvendus`, etc.
3. **Structure des modèles** : Les modèles ont été mis à jour pour correspondre à la structure des tables SQL.
4. **Relations entre les tables** : Les relations ont été mises à jour pour correspondre aux relations dans la base SQL.

## Nouveaux modèles

Les anciens modèles ont été remplacés par de nouveaux modèles qui correspondent à la structure de la base de données SQL :

| Ancien modèle | Nouveau modèle |
|---------------|----------------|
| `User` | `MarketplaceUser` |
| `Fisherman` | `MarketplacePecheur` |
| `Fish` | `MarketplaceProduit` |
| `Review` | `MarketplaceAvis` |
| `Order` | `MarketplaceAommande` |
| `OrderItem` | `MarketplaceProduitVendus` |
| `Lot` | `MarketplaceLots` |
| `Catch` | `MarketplacePrise` |
| `Message` | `MarketplaceMessage` |
| `Conversation` | `MarketplaceSalon` |
| `Payment` | `MarketplacePanier` |

## Utilitaires de migration

Pour faciliter la transition vers les nouveaux modèles, plusieurs utilitaires ont été créés :

1. **`model_bridge.dart`** : Fournit des extensions pour accéder aux propriétés des anciens modèles à partir des nouveaux modèles.
2. **`model_migration.dart`** : Fournit des méthodes pour convertir entre les anciens et nouveaux modèles.
3. **`service_migration.dart`** : Fournit des méthodes pour faciliter la migration des services.
4. **`screen_migration.dart`** : Fournit des widgets et des méthodes pour faciliter la migration des écrans.

## Comment utiliser les utilitaires de migration

### Accéder aux propriétés des anciens modèles

```dart
import '../utils/model_bridge.dart';

// Accéder aux propriétés de l'ancien modèle Fish
final produit = MarketplaceProduit(...);
final fishId = ModelBridge.MarketplaceProduitBridge(produit).id;
final fishermanId = ModelBridge.MarketplaceProduitBridge(produit).fishermanId;
final species = ModelBridge.MarketplaceProduitBridge(produit).species;
```

### Convertir entre les anciens et nouveaux modèles

```dart
import '../utils/model_migration.dart';

// Convertir un ancien modèle Fish en MarketplaceProduit
final fishMap = {
  'id': '123',
  'species': 'Bar commun',
  'description': 'Un poisson frais',
  'price': 15.90,
  'quantity': 10,
  'fishermanId': '456',
  'category': 'Poisson',
  'captureDate': '2023-01-01',
  'location': 'Côte atlantique',
};
final produit = ModelMigration.fishToProduit(fishMap);
```

### Créer de nouveaux modèles

```dart
import '../utils/service_migration.dart';

// Créer un nouveau produit
final produit = ServiceMigration.createProduit(
  nom: 'Bar commun',
  description: 'Un poisson frais',
  prix: 15.90,
  stock: 10,
  userId: 456,
  typologie: 'Poisson',
  dateDePeche: '2023-01-01',
  zoneDePeche: 'Côte atlantique',
);
```

### Afficher des widgets

```dart
import '../utils/screen_migration.dart';

// Afficher un widget de produit
final produit = MarketplaceProduit(...);
final widget = ScreenMigration.buildProductCard(
  context,
  produit,
  () => Navigator.push(...),
);
```

## Prochaines étapes

1. Mettre à jour tous les services pour utiliser les nouveaux modèles
2. Mettre à jour tous les écrans pour utiliser les nouveaux modèles
3. Supprimer les références aux anciens modèles
4. Ajouter des tests unitaires pour vérifier que tout fonctionne correctement
