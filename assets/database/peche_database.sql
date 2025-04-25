-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : mgsnixvdb.mysql.db
-- Généré le : ven. 04 avr. 2025 à 16:24
-- Version du serveur : 8.0.40-31
-- Version de PHP : 8.1.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `mgsnixvdb`
--

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_actualite`
--

CREATE TABLE `marketplace_actualite` (
  `id` int NOT NULL,
  `titre` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `description` varchar(3000) COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)',
  `image` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_administrateur`
--

CREATE TABLE `marketplace_administrateur` (
  `id` int NOT NULL,
  `email` varchar(191) COLLATE utf8mb3_unicode_ci NOT NULL,
  `roles` json NOT NULL,
  `password` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `nom` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `prenom` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cin` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `matricule` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `etablissement` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `telephone` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_administrateur`
--

INSERT INTO `marketplace_administrateur` (`id`, `email`, `roles`, `password`, `nom`, `prenom`, `cin`, `matricule`, `etablissement`, `telephone`) VALUES
(1, 'jabriskander@gmail.com', '[\"ROLE_ADMIN_CRIER\"]', '$argon2id$v=19$m=65536,t=4,p=1$rIhVQoHVA9jqKnRL/gU42g$xOY834q+TJEw3XxkwQZgKHXOn+E7NPtiLSRJm6HZbBo', 'iskander', 'jabri', NULL, NULL, 'VET', 29082245),
(2, 'test@gmail.com', '[\"ROLE_VIWER\"]', '$argon2id$v=19$m=65536,t=4,p=1$OTbSUuZa3zed+9xisPyJug$bDMSPUUAnBEn56X+14C6Y0Dy5h1jMV/8SSmhix2Yrn4', 'jabriskander361@gmail.com', '12345678', NULL, NULL, 'POLE', 12344323),
(4, 'test1@gmail.com', '[\"ROLE_VIWER\"]', '$argon2id$v=19$m=65536,t=4,p=1$G3g4muujDT8YB+fzAAnkUA$6Q/azMsHwyCn6crMnTyBCZfmzGN2dwu5EtR3Gr1KoPc', 'jabriskander361@gmail.coma', '12345678', NULL, NULL, 'POLE', 12344323),
(5, 'test12@gmail.com', '[\"ROLE_VIWER\"]', '$argon2id$v=19$m=65536,t=4,p=1$A/XqtS/8HHJpgDfmTJhOFQ$KUPzOzjOhzjRnXdlBh0cejAnJTUaolwjEvPPlT+r5S8', 'jabriskander361@gmail.coma', '12345678', NULL, NULL, 'POLE', 12344323),
(6, 'test123@gmail.com', '[\"ROLE_VIWER\"]', '$argon2id$v=19$m=65536,t=4,p=1$IX6j4w2G/Vh8c3bPLsJqZQ$3BMZX4hEDSbVdAqZsCNPVcK557F+0mhM2YSl+NTv7vQ', 'jabriskander361@gmail.coma', '12345678', NULL, NULL, 'POLE', 12344323),
(7, 'houssem', '[\"ROLE_ADMIN_CRIER\"]', '$argon2id$v=19$m=65536,t=4,p=1$3o48dzM31Zh29jB9S+dksA$HilTFGM0cVB327E3Bp+sG5AxAsJZ8l/1A825DN2VO9Q', 'houssem', 'alayet', NULL, NULL, 'VET', 29082245);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_annonce`
--

CREATE TABLE `marketplace_annonce` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `titre` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `image` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `categorie` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `date` datetime NOT NULL,
  `etat` int NOT NULL,
  `vu` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_annonce`
--

INSERT INTO `marketplace_annonce` (`id`, `user_id`, `titre`, `description`, `image`, `categorie`, `date`, `etat`, `vu`) VALUES
(6, 37, 'new annonce', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s', 'de1a8ae620c95be334e065223906d491.jpeg', 'Annonce', '2022-12-16 17:04:21', 0, 2),
(7, 37, 'new formation', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s', '33cdeddcf4f620818988da553723bc97.jpeg', 'Formation', '2022-12-16 17:04:50', 0, NULL),
(8, 37, 'stage de peche', 'test test', '1c67c7eacf61e8961ccbb2cc2f5e56ab.jpeg', 'Stage', '2022-12-16 17:10:05', 0, NULL),
(9, 37, 'projet et autofinancement', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s', '9fadd4128b134fb8d54404547346a3de.jpeg', 'Finnance et assurance', '2022-12-16 17:10:41', 0, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_aommande`
--

CREATE TABLE `marketplace_aommande` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `methode_de_paiement` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `commentaire` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `totale` double NOT NULL,
  `statut_commande` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)',
  `date_modification` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)',
  `reference` varchar(191) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `fournisseur_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_aommande`
--

INSERT INTO `marketplace_aommande` (`id`, `user_id`, `methode_de_paiement`, `commentaire`, `totale`, `statut_commande`, `created_at`, `date_modification`, `reference`, `fournisseur_id`) VALUES
(96, 37, 'cash on delivery', '', 1066.4, 'Livrée', '2024-10-15 22:56:22', '2024-10-15 23:51:51', 'GIPP4FD0E009307DEBA74BDD', 118),
(97, 37, 'cash on delivery', '', 30000, 'En Cours', '2024-10-15 22:56:24', '2024-10-15 22:56:24', 'GIPP892D2223AAD721534A5C', 118),
(101, 134, 'cash on delivery', '', 1066.4, 'Livrée', '2024-10-15 23:28:09', '2024-10-15 23:53:09', 'GIPP4C0AF798CE5FCE86F497', 37),
(102, 37, 'cash on delivery', '', 533.2, 'En Cours', '2024-10-15 23:28:11', '2024-10-15 23:28:11', 'GIPPF19C68B1B72FE6C7991A', 37),
(103, 134, 'cash on delivery', '', 533.2, 'Livrée', '2024-11-07 08:34:16', '2025-04-04 11:29:15', 'GIPPC5176077AD03D64A1C5A', 37);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_avis`
--

CREATE TABLE `marketplace_avis` (
  `id` int NOT NULL,
  `produit_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `etoile_nb` int NOT NULL,
  `commentaire` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_avis`
--

INSERT INTO `marketplace_avis` (`id`, `produit_id`, `user_id`, `etoile_nb`, `commentaire`, `created_at`) VALUES
(1, 11, 37, 4, 'bien ', '2023-09-08 16:14:15'),
(4, 11, 37, 2, 'hi', '2024-04-28 14:08:32'),
(5, 11, 37, 3, 'niceJJJJjjjjjjjjjjjjjjjjjjjjjjjjjjJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJdfjidjfidjfidjfidjifdjfidjfijdfidid', '2024-04-28 22:12:25'),
(6, 11, 137, 3, 'niceJJJkdcnkfngfjgkfjgkjgkjfkgkfjgkfjgkfjgkfgjdcjdcjdhcjdhcjJjjjjjjjjjj\r\njjjjjjjjjjjjjjjjJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ\r\nJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ\r\ndjbdjfhjdhfjhd\r\ndfkdhkfdkfhdkhfkdf\r\ndkfbdkhkdhdkf\r\ndfbdkfkdf djfbjdfjdfjd dfdfjdbkfjhdjkf', '2024-04-28 22:12:25'),
(7, 11, 37, 1, 'hi', '2024-11-06 15:17:35'),
(8, 11, 37, 2, 'nice ', '2024-11-06 16:08:46');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_categorie`
--

CREATE TABLE `marketplace_categorie` (
  `id` int NOT NULL,
  `nom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `image_url` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_categorie`
--

INSERT INTO `marketplace_categorie` (`id`, `nom`, `image_url`) VALUES
(3, 'Sury', '88de06fe19e7af95969f73163910cb79.jpeg'),
(4, 'Thon', 'd7fb720a3dd418a1c184abb9fb017ae4.jpeg'),
(5, 'Merlu', '577976ad685cebaa9b4a61bf77702a20.jpeg'),
(6, 'Saumon', 'ddb982fc843a2280d5fe10049c1c3684.jpeg'),
(7, 'Calmar', '958b0b4545acf1a3e46859cc3f5a56f8.jpeg'),
(8, 'Crevette (Crevette)', '103f02414b34d6f9d4e04304e2ffc0da.jpeg'),
(9, 'Carpi', '93a16a857915395a2e0f0c3c8fff81f0.jpeg'),
(10, 'Murue', '052d0601f97d1601a7da372b0cbbadd0.jpeg');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_categorie_comment`
--

CREATE TABLE `marketplace_categorie_comment` (
  `id` int NOT NULL,
  `nom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_categorie_comment`
--

INSERT INTO `marketplace_categorie_comment` (`id`, `nom`) VALUES
(1, 'Actualité'),
(2, 'Opportunité d\'affaire'),
(3, 'Matériel professionnel'),
(4, 'Immobilier'),
(5, 'Services'),
(6, 'Finance-Assurance'),
(7, 'Transport-logistiques'),
(8, 'Edition-Multimédia'),
(9, 'Formation-Conférences'),
(10, 'Emploi-Stage'),
(11, 'Divers');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_commande_equipement`
--

CREATE TABLE `marketplace_commande_equipement` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `fournisseur_id` int DEFAULT NULL,
  `methode_de_paiement` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `commentaire` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `totale` double NOT NULL,
  `statut_commande` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)',
  `date_modification` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)',
  `reference` varchar(191) COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_comments`
--

CREATE TABLE `marketplace_comments` (
  `id` int NOT NULL,
  `forum_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `message` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_comments`
--

INSERT INTO `marketplace_comments` (`id`, `forum_id`, `user_id`, `message`, `date`) VALUES
(1, 1, 37, 'L\'inflation alimentaire peut avoir des conséquences graves sur la sécurité alimentaire et la nutrition des populations', '2023-01-04 15:36:56'),
(2, 1, 37, 'De plus, l\'inflation alimentaire peut entraîner une instabilité économique et politique dans les pays en développement', '2023-01-04 15:45:45'),
(3, 1, 37, 'aaa', '2023-09-25 16:45:54'),
(4, 1, 137, 'aaa', '2023-09-25 16:46:07'),
(5, 2, 137, 'aaa', '2023-09-25 16:46:21'),
(6, 4, 37, 'aaa', '2023-09-25 16:47:15'),
(7, 5, 37, 'wwxwxwxw', '2023-09-25 18:09:43'),
(8, 5, 137, 'wwxwxwxw', '2023-09-25 18:09:49'),
(9, 1, 37, 'qssqsqsq', '2023-09-25 18:10:34'),
(36, 6, 37, 'hi', '2024-04-26 08:31:41'),
(37, 7, 38, 'nice', '2025-04-04 11:24:26');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_contact`
--

CREATE TABLE `marketplace_contact` (
  `id` int NOT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `body` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `readed` int NOT NULL,
  `date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_contact`
--

INSERT INTO `marketplace_contact` (`id`, `subject`, `body`, `email`, `readed`, `date`) VALUES
(3, 'test', 'test tes', 'test@gmail.com', 1, '2022-11-16'),
(5, 'création de compte ', 'aaaaaaaaaaaaaaaaaaaaajscjjdhjdhjdhjdhjdhjdhjdhjdhjdhjdhjdhdjhdjhjhdjhjdhjdhjdhjdhjdhjdhdjdhjdjdhjdhjdhjdjdhjdjdhjdhjdjdhdjjd', 'jabriskander361@gmail.com', 1, '2023-09-06'),
(6, 'test', 'test', 'jabriskander361@gmail.com', 1, '2023-09-25'),
(7, 'aaaaaaa', 'aaaaaa', 'abirrebei9@gmail.com', 0, '2023-09-25'),
(8, 'aaaa', 'aaaa', 'sbouis@yahoo.fr', 0, '2023-09-25'),
(9, 'hi', 'hi', 'amenisyrine@gmail.com', 1, '2023-09-25'),
(10, 'gipp', 'slksjdksj', 'amenisyrine@gmail.com', 0, '2024-04-28'),
(11, 'gipp', 'slksjdksj', 'amenisyrine@gmail.com', 1, '2024-04-28'),
(12, 'gipp', 'nice', 'briksyrine12@gmail.com', 0, '2024-09-03'),
(13, 'GIPP', 'HIII', 'briksyrine12@gmail.com', 0, '2024-09-03'),
(14, 'gipp', 'hi', 'briksyrine12@gmail.com', 0, '2024-09-03'),
(15, 'gipp', 'hi', 'briksyrine12@gmail.com', 0, '2024-09-03'),
(16, 'gipp', 'hi', 'briksyrine12@gmail.com', 1, '2024-09-03'),
(17, 'gipp', 'nice', 'briksyrine12@gmail.com', 1, '2024-09-03'),
(18, 'Question', 'bonjour', 'briksyrine12@gmail.com', 1, '2025-04-04');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_country`
--

CREATE TABLE `marketplace_country` (
  `id` int NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `val` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_country`
--

INSERT INTO `marketplace_country` (`id`, `name`, `val`) VALUES
(833, 'Afghanistan', 'AF'),
(834, 'Albania', 'AL'),
(835, 'Algeria', 'DZ'),
(836, 'American Samoa', 'AS'),
(837, 'Andorra', 'AD'),
(838, 'Angola', 'AO'),
(839, 'Anguilla', 'AI'),
(840, 'Antarctica', 'AQ'),
(841, 'Antigua and Barbuda', 'AG'),
(842, 'Argentina', 'AR'),
(843, 'Armenia', 'AM'),
(844, 'Aruba', 'AW'),
(845, 'Australia', 'AU'),
(846, 'Austria', 'AT'),
(847, 'Azerbaijan', 'AZ'),
(848, 'Bahamas', 'BS'),
(849, 'Bahrain', 'BH'),
(850, 'Bangladesh', 'BD'),
(851, 'Barbados', 'BB'),
(852, 'Belarus', 'BY'),
(853, 'Belgium', 'BE'),
(854, 'Belize', 'BZ'),
(855, 'Benin', 'BJ'),
(856, 'Bermuda', 'BM'),
(857, 'Bhutan', 'BT'),
(858, 'Bolivia', 'BO'),
(859, 'Bosnia and Herzegovina', 'BA'),
(860, 'Botswana', 'BW'),
(861, 'Bouvet Island', 'BV'),
(862, 'Brazil', 'BR'),
(863, 'British Antarctic Territory', 'BQ'),
(864, 'British Indian Ocean Territory', 'IO'),
(865, 'British Virgin Islands', 'VG'),
(866, 'Brunei', 'BN'),
(867, 'Bulgaria', 'BG'),
(868, 'Burkina Faso', 'BF'),
(869, 'Burundi', 'BI'),
(870, 'Cambodia', 'KH'),
(871, 'Cameroon', 'CM'),
(872, 'Canada', 'CA'),
(873, 'Canton and Enderbury Islands', 'CT'),
(874, 'Cape Verde', 'CV'),
(875, 'Cayman Islands', 'KY'),
(876, 'Central African Republic', 'CF'),
(877, 'Chad', 'TD'),
(878, 'Chile', 'CL'),
(879, 'China', 'CN'),
(880, 'Christmas Island', 'CX'),
(881, 'Cocos [Keeling] Islands', 'CC'),
(882, 'Colombia', 'CO'),
(883, 'Comoros', 'KM'),
(884, 'Congo - Brazzaville', 'CG'),
(885, 'Congo - Kinshasa', 'CD'),
(886, 'Cook Islands', 'CK'),
(887, 'Costa Rica', 'CR'),
(888, 'Croatia', 'HR'),
(889, 'Cuba', 'CU'),
(890, 'Cyprus', 'CY'),
(891, 'Czech Republic', 'CZ'),
(892, 'Côte d’Ivoire', 'CI'),
(893, 'Denmark', 'DK'),
(894, 'Djibouti', 'DJ'),
(895, 'Dominica', 'DM'),
(896, 'Dominican Republic', 'DO'),
(897, 'Dronning Maud Land', 'NQ'),
(898, 'East Germany', 'DD'),
(899, 'Ecuador', 'EC'),
(900, 'Egypt', 'EG'),
(901, 'El Salvador', 'SV'),
(902, 'Equatorial Guinea', 'GQ'),
(903, 'Eritrea', 'ER'),
(904, 'Estonia', 'EE'),
(905, 'Ethiopia', 'ET'),
(906, 'Falkland Islands', 'FK'),
(907, 'Faroe Islands', 'FO'),
(908, 'Fiji', 'FJ'),
(909, 'Finland', 'FI'),
(910, 'France', 'FR'),
(911, 'French Guiana', 'GF'),
(912, 'French Polynesia', 'PF'),
(913, 'French Southern Territories', 'TF'),
(915, 'Gabon', 'GA'),
(916, 'Gambia', 'GM'),
(917, 'Georgia', 'GE'),
(918, 'Germany', 'DE'),
(919, 'Ghana', 'GH'),
(920, 'Gibraltar', 'GI'),
(921, 'Greece', 'GR'),
(922, 'Greenland', 'GL'),
(923, 'Grenada', 'GD'),
(924, 'Guadeloupe', 'GP'),
(925, 'Guam', 'GU'),
(926, 'Guatemala', 'GT'),
(927, 'Guernsey', 'GG'),
(928, 'Guinea', 'GN'),
(929, 'Guinea-Bissau', 'GW'),
(930, 'Guyana', 'GY'),
(931, 'Haiti', 'HT'),
(932, 'Heard Island and McDonald Islands', 'HM'),
(933, 'Honduras', 'HN'),
(934, 'Hong Kong SAR China', 'HK'),
(935, 'Hungary', 'HU'),
(936, 'Iceland', 'IS'),
(937, 'India', 'IN'),
(938, 'Indonesia', 'ID'),
(939, 'Iran', 'IR'),
(940, 'Iraq', 'IQ'),
(941, 'Ireland', 'IE'),
(942, 'Isle of Man', 'IM'),
(943, 'Israel', 'IL'),
(944, 'Italy', 'IT'),
(945, 'Jamaica', 'JM'),
(946, 'Japan', 'JP'),
(947, 'Jersey', 'JE'),
(948, 'Johnston Island', 'JT'),
(949, 'Jordan', 'JO'),
(950, 'Kazakhstan', 'KZ'),
(951, 'Kenya', 'KE'),
(952, 'Kiribati', 'KI'),
(953, 'Kuwait', 'KW'),
(954, 'Kyrgyzstan', 'KG'),
(955, 'Laos', 'LA'),
(956, 'Latvia', 'LV'),
(957, 'Lebanon', 'LB'),
(958, 'Lesotho', 'LS'),
(959, 'Liberia', 'LR'),
(960, 'Libya', 'LY'),
(961, 'Liechtenstein', 'LI'),
(962, 'Lithuania', 'LT'),
(963, 'Luxembourg', 'LU'),
(964, 'Macau SAR China', 'MO'),
(965, 'Macedonia', 'MK'),
(966, 'Madagascar', 'MG'),
(967, 'Malawi', 'MW'),
(968, 'Malaysia', 'MY'),
(969, 'Maldives', 'MV'),
(970, 'Mali', 'ML'),
(971, 'Malta', 'MT'),
(972, 'Marshall Islands', 'MH'),
(973, 'Martinique', 'MQ'),
(974, 'Mauritania', 'MR'),
(975, 'Mauritius', 'MU'),
(976, 'Mayotte', 'YT'),
(977, 'Metropolitan France', 'FX'),
(978, 'Mexico', 'MX'),
(979, 'Micronesia', 'FM'),
(980, 'Midway Islands', 'MI'),
(981, 'Moldova', 'MD'),
(982, 'Monaco', 'MC'),
(983, 'Mongolia', 'MN'),
(984, 'Montenegro', 'ME'),
(985, 'Montserrat', 'MS'),
(986, 'Morocco', 'MA'),
(987, 'Mozambique', 'MZ'),
(988, 'Myanmar [Burma]', 'MM'),
(989, 'Namibia', 'NA'),
(990, 'Nauru', 'NR'),
(991, 'Nepal', 'NP'),
(992, 'Netherlands', 'NL'),
(993, 'Netherlands Antilles', 'AN'),
(994, 'Neutral Zone', 'NT'),
(995, 'New Caledonia', 'NC'),
(996, 'New Zealand', 'NZ'),
(997, 'Nicaragua', 'NI'),
(998, 'Niger', 'NE'),
(999, 'Nigeria', 'NG'),
(1000, 'Niue', 'NU'),
(1001, 'Norfolk Island', 'NF'),
(1002, 'North Korea', 'KP'),
(1003, 'North Vietnam', 'VD'),
(1004, 'Northern Mariana Islands', 'MP'),
(1005, 'Norway', 'NO'),
(1006, 'Oman', 'OM'),
(1007, 'Pacific Islands Trust Territory', 'PC'),
(1008, 'Pakistan', 'PK'),
(1009, 'Palau', 'PW'),
(1010, 'Palestinian Territories', 'PS'),
(1011, 'Panama', 'PA'),
(1012, 'Panama Canal Zone', 'PZ'),
(1013, 'Papua New Guinea', 'PG'),
(1014, 'Paraguay', 'PY'),
(1016, 'Peru', 'PE'),
(1017, 'Philippines', 'PH'),
(1018, 'Pitcairn Islands', 'PN'),
(1019, 'Poland', 'PL'),
(1020, 'Portugal', 'PT'),
(1021, 'Puerto Rico', 'PR'),
(1022, 'Qatar', 'QA'),
(1023, 'Romania', 'RO'),
(1024, 'Russia', 'RU'),
(1025, 'Rwanda', 'RW'),
(1026, 'Réunion', 'RE'),
(1027, 'Saint Barthélemy', 'BL'),
(1028, 'Saint Helena', 'SH'),
(1029, 'Saint Kitts and Nevis', 'KN'),
(1030, 'Saint Lucia', 'LC'),
(1031, 'Saint Martin', 'MF'),
(1032, 'Saint Pierre and Miquelon', 'PM'),
(1033, 'Saint Vincent and the Grenadines', 'VC'),
(1034, 'Samoa', 'WS'),
(1035, 'San Marino', 'SM'),
(1036, 'Saudi Arabia', 'SA'),
(1037, 'Senegal', 'SN'),
(1038, 'Serbia', 'RS'),
(1039, 'Serbia and Montenegro', 'CS'),
(1040, 'Seychelles', 'SC'),
(1041, 'Sierra Leone', 'SL'),
(1042, 'Singapore', 'SG'),
(1043, 'Slovakia', 'SK'),
(1044, 'Slovenia', 'SI'),
(1045, 'Solomon Islands', 'SB'),
(1046, 'Somalia', 'SO'),
(1047, 'South Africa', 'ZA'),
(1049, 'South Korea', 'KR'),
(1050, 'Spain', 'ES'),
(1051, 'Sri Lanka', 'LK'),
(1052, 'Sudan', 'SD'),
(1053, 'Suriname', 'SR'),
(1054, 'Svalbard and Jan Mayen', 'SJ'),
(1055, 'Swaziland', 'SZ'),
(1056, 'Sweden', 'SE'),
(1057, 'Switzerland', 'CH'),
(1058, 'Syria', 'SY'),
(1059, 'São Tomé and Príncipe', 'ST'),
(1060, 'Taiwan', 'TW'),
(1061, 'Tajikistan', 'TJ'),
(1062, 'Tanzania', 'TZ'),
(1063, 'Thailand', 'TH'),
(1064, 'Timor-Leste', 'TL'),
(1065, 'Togo', 'TG'),
(1066, 'Tokelau', 'TK'),
(1067, 'Tonga', 'TO'),
(1068, 'Trinidad and Tobago', 'TT'),
(1069, 'Tunisia', 'TN'),
(1070, 'Turkey', 'TR'),
(1071, 'Turkmenistan', 'TM'),
(1072, 'Turks and Caicos Islands', 'TC'),
(1073, 'Tuvalu', 'TV'),
(1074, 'U.S. Minor Outlying Islands', 'UM'),
(1075, 'U.S. Miscellaneous Pacific Islands', 'PU'),
(1076, 'U.S. Virgin Islands', 'VI'),
(1077, 'Uganda', 'UG'),
(1078, 'Ukraine', 'UA'),
(1079, 'Union of Soviet Socialist Republics', 'SU'),
(1080, 'United Arab Emirates', 'AE'),
(1081, 'United Kingdom', 'GB'),
(1082, 'United States', 'US'),
(1083, 'Unknown or Invalid Region', 'ZZ'),
(1084, 'Uruguay', 'UY'),
(1085, 'Uzbekistan', 'UZ'),
(1086, 'Vanuatu', 'VU'),
(1087, 'Vatican City', 'VA'),
(1088, 'Venezuela', 'VE'),
(1089, 'Vietnam', 'VN'),
(1090, 'Wake Island', 'WK'),
(1091, 'Wallis and Futuna', 'WF'),
(1092, 'Western Sahara', 'EH'),
(1093, 'Yemen', 'YE'),
(1094, 'Zambia', 'ZM'),
(1095, 'Zimbabwe', 'ZW'),
(1096, 'Åland Islands', 'AX');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_engene`
--

CREATE TABLE `marketplace_engene` (
  `id` int NOT NULL,
  `nom` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_entreprise`
--

CREATE TABLE `marketplace_entreprise` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `nom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `adresse` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `pays` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `code_postal` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `document_de_reference` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `lat` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `lng` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `logo` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `region` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `mobile` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `whatsapp` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `fax` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `site` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `facebook` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `instagramme` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tweeter` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `linkedin` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `activite` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `ville` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `tva` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `imm` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `datecreation` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `immatriculation` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `certificat` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tel` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `kbis` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `about` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `forme_juridique` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `nb_employe` int DEFAULT NULL,
  `chiffre_affaire_annuel` int DEFAULT NULL,
  `heures_ouverture` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `capital` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_entreprise`
--

INSERT INTO `marketplace_entreprise` (`id`, `user_id`, `nom`, `adresse`, `pays`, `code_postal`, `document_de_reference`, `lat`, `lng`, `logo`, `region`, `mobile`, `whatsapp`, `fax`, `site`, `facebook`, `instagramme`, `tweeter`, `linkedin`, `activite`, `email`, `ville`, `tva`, `imm`, `datecreation`, `immatriculation`, `certificat`, `tel`, `kbis`, `about`, `forme_juridique`, `nb_employe`, `chiffre_affaire_annuel`, `heures_ouverture`, `capital`) VALUES
(14, 37, 'Harikaseafood', ' 90046 - Palerme, Sicile', 'Italie', '8115', NULL, '36.80278', '10.17972', '38d00e9f3ed6d1648085d8ab7b05dd26.png', 'Sicile', '+39 340 123 546', '+39 340 123 546', '778899900', 'www.Harikaseafood.com', 'facebook', 'instagramme', 'tweeter', 'linkedin', 'Aquaculture', 'harikaseafood@contact.com', 'Sicile', '1234566789', 'hi', '16/05/2024', '76bb42538a230b375b971fbcf1aee6a4.doc', '82d25cb9c2d9b465a6208c546ffec643.pdf', '73456667', '415f8ee3bf1968422095f3c24836db9e.pdf', '', NULL, NULL, NULL, '{\"Lundi\":{\"open\":true,\"from\":\"2024-09-27T11:53:00.000Z\",\"to\":\"2024-09-27T12:53:00.000Z\"},\"Mardi\":{\"open\":true,\"from\":\"2024-09-27T12:42:00.000Z\",\"to\":\"2024-09-27T16:47:00.000Z\"},\"Mercredi\":{\"open\":false,\"from\":null,\"to\":null},\"Jeudi\":{\"open\":false,\"from\":null,\"to\":null},\"Vendredi\":{\"open\":false,\"from\":null,\"to\":null},\"Samedi\":{\"open\":false,\"from\":null,\"to\":null},\"Dimanche\":{\"open\":false,\"from\":null,\"to\":null}}', NULL),
(67, 118, 'Le Pêcheur', '6 Rue d\'Alger, Tunis, Gouvernorat de Tunis, Tunisie', 'Tunisie', '2000', NULL, '36.80373948435451', '10.137690217471834', 'd2f9b19d67efa9682f1d808721fbe497.jpeg', 'Nord Tunisie', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Restauration', 'lepecheur@gmail.com', 'Tunis', 'FR12345', NULL, '23/12/2011', '1234567890123', NULL, '71661491', NULL, 'Restaurant Le Pêcheur offre un service professionnel à ses visiteurs. Une atmosphère confortable a été remarquée par les clients. Google lui donne un score de 4.1, vous pouvez donc choisir ce lieu pour y passer du bon temps.', 'SARL', 45, 1234567, '{\"Lundi\":{\"open\":true,\"from\":\"2024-12-18T10:00:00.000Z\",\"to\":\"2024-12-17T23:00:00.000Z\"},\"Mardi\":{\"open\":true,\"from\":\"2024-12-18T10:00:00.000Z\",\"to\":\"2024-12-17T23:00:00.000Z\"},\"Mercredi\":{\"open\":true,\"from\":\"2024-12-18T10:00:00.000Z\",\"to\":\"2024-12-17T23:00:00.000Z\"},\"Jeudi\":{\"open\":true,\"from\":\"2024-12-18T10:00:00.000Z\",\"to\":\"2024-12-17T23:00:00.000Z\"},\"Vendredi\":{\"open\":true,\"from\":\"2024-12-18T10:00:00.000Z\",\"to\":\"2024-12-17T23:00:00.000Z\"},\"Samedi\":{\"open\":true,\"from\":\"2024-12-18T10:00:00.000Z\",\"to\":\"2024-12-17T23:00:00.000Z\"},\"Dimanche\":{\"open\":true,\"from\":\"2024-12-18T10:00:00.000Z\",\"to\":\"2024-12-17T23:00:00.000Z\"}}', 1234567);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_equipement`
--

CREATE TABLE `marketplace_equipement` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `titre` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `prix` double NOT NULL,
  `stock` int NOT NULL,
  `discount` double DEFAULT NULL,
  `visibilite` tinyint(1) NOT NULL,
  `categorie` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `vue` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_equipement`
--

INSERT INTO `marketplace_equipement` (`id`, `user_id`, `titre`, `description`, `prix`, `stock`, `discount`, `visibilite`, `categorie`, `vue`) VALUES
(12, 39, 'test equipement', 'TEST', 400, 49, NULL, 1, 'MOLETNET', 0),
(13, 44, 'moulinet new', 'test moulinet', 200, 100, NULL, 1, 'MOLETNET', 0),
(14, 45, 'moteur ', 'TEST ', 100, 200, NULL, 1, 'MOLETNET', 0);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_equipementvendus`
--

CREATE TABLE `marketplace_equipementvendus` (
  `id` int NOT NULL,
  `commandeequipement_id` int DEFAULT NULL,
  `equipement_id` int DEFAULT NULL,
  `nom` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `quantite` int NOT NULL,
  `prix` double NOT NULL,
  `totale` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_espece`
--

CREATE TABLE `marketplace_espece` (
  `id` int NOT NULL,
  `nom` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `image_url` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_espece`
--

INSERT INTO `marketplace_espece` (`id`, `nom`, `image_url`) VALUES
(1, 'قمبري ملكي', ''),
(2, 'قمبري أبيض ', ''),
(3, 'لنقوسطة', ''),
(4, 'كلمار', ''),
(5, 'قرنيط', ''),
(6, 'سوبيا', ''),
(7, 'بومسك', ''),
(8, 'مرجان', ''),
(9, 'تريلية حمراء', ''),
(10, 'تريلية بيضاء', ''),
(11, 'جغالي', ''),
(12, 'مداس', ''),
(13, 'قاروص', ''),
(14, 'وراطة', ''),
(15, 'بوري', ''),
(16, 'صبارص', ''),
(17, 'بوكشاش', ''),
(18, 'دنديق', '');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_forum`
--

CREATE TABLE `marketplace_forum` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `titre` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `date` datetime NOT NULL,
  `vue` int NOT NULL,
  `comment` int NOT NULL,
  `categorie_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_forum`
--

INSERT INTO `marketplace_forum` (`id`, `user_id`, `titre`, `description`, `date`, `vue`, `comment`, `categorie_id`) VALUES
(1, 37, 'Mieux contrôler son inflation alimentaire', 'L\'inflation alimentaire est une hausse générale et durable des prix des produits alimentaires. Elle peut être causée par des facteurs tels que la croissance de la demande, la baisse de l\'offre, les coûts de production plus élevés, les problèmes climatique', '2023-01-04 14:23:04', 115, 27, 1),
(2, 37, 'Comment le TMM peut-il influencer la politique monétaire d\'un pays ?', 'Le Taux Moyen du Marché Monétaire (TMM) est un indicateur clé du marché monétaire, qui mesure le taux d\'intérêt moyen des transactions effectuées entre les banques et les autres institutions financières à court terme', '2023-01-04 14:24:01', 19, 3, 1),
(3, 137, 'Les chiffres du commerce international', 'Le commerce extérieur de la Tunisie représente 104% de son PIB (Banque mondiale, 2018). La fabrication de fils et câbles continue d\'être la principale industrie exportatrice de la Tunisie (13,2% de toutes les exportations)', '2023-01-19 13:55:12', 9, 0, 2),
(4, 37, 'test', 'test', '2023-09-25 16:08:45', 2, 1, 1),
(5, 37, 'Italy', 'Italy Sicilia', '2023-09-25 18:09:04', 4, 2, 1),
(6, 137, 'bateau', 'bateau a vendre', '2023-09-25 18:09:23', 4, 1, 3),
(7, 37, 'salut', 'test', '2023-09-26 12:03:18', 9, 1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_image`
--

CREATE TABLE `marketplace_image` (
  `id` int NOT NULL,
  `produit_id` int DEFAULT NULL,
  `image_url` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_image`
--

INSERT INTO `marketplace_image` (`id`, `produit_id`, `image_url`) VALUES
(14, 9, 'cat1.jpg'),
(15, 10, 'cat2.jpg'),
(16, 11, 'cat3.jpg'),
(17, 12, 'cat4.jpg'),
(18, 13, 'cat6.jpg'),
(19, 14, 'cat5.jpg'),
(20, 15, '6784da38219d4d69415a0dd720c2886b.jpeg'),
(21, 9, 'cat2.jpg'),
(22, 16, 'e1642e10ea7cf91763bf52cfc58992b5.jpeg'),
(23, 18, 'f08696778d127e11782f99512268e668.png'),
(25, 24, '63d572b6d79f39ce1018e51c22cf583c.png'),
(26, 24, 'd0c2e9fab69bdc9ae638f075c3dc6186.png'),
(27, 25, 'd0c2e9fab69bdc9ae638f075c3dc6186.png'),
(28, 26, 'd0c2e9fab69bdc9ae638f075c3dc6186.png'),
(29, 27, 'd0c2e9fab69bdc9ae638f075c3dc6186.png'),
(30, 28, '63618c4a211dd6e81a800a8a4fa6b8a1.jpeg');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_image_equipement`
--

CREATE TABLE `marketplace_image_equipement` (
  `id` int NOT NULL,
  `produit_id` int DEFAULT NULL,
  `image_url` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_image_equipement`
--

INSERT INTO `marketplace_image_equipement` (`id`, `produit_id`, `image_url`) VALUES
(5, 12, 'f4a08a21467b84470d4a957ae4171fde.jpeg'),
(6, 13, 'ac8717da72f9f2d078d3ca33c4542954.jpeg'),
(7, 14, 'cf07cc0e0df026a5ef4d0b959eaf7716.jpeg');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_lots`
--

CREATE TABLE `marketplace_lots` (
  `id` int NOT NULL,
  `rfid_id` int DEFAULT NULL,
  `vitirinaire_id` int DEFAULT NULL,
  `identifiant` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `photo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `quantite` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `poid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `espece` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `temperature` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `prixinitial` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `prixminimal` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `prixfinale` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `datetest` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `test` tinyint(1) DEFAULT NULL,
  `status` tinyint(1) DEFAULT NULL,
  `vendre` tinyint(1) DEFAULT NULL,
  `prise_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `datesoumettre` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `poidestimatif` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `typeenchere` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `current` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `online` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `is_produit` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_lots`
--

INSERT INTO `marketplace_lots` (`id`, `rfid_id`, `vitirinaire_id`, `identifiant`, `photo`, `quantite`, `poid`, `espece`, `temperature`, `prixinitial`, `prixminimal`, `prixfinale`, `datetest`, `test`, `status`, `vendre`, `prise_id`, `user_id`, `datesoumettre`, `poidestimatif`, `typeenchere`, `current`, `online`, `is_produit`) VALUES
(44, 34, NULL, '56', 'Lamboukaa.jpeg', '25', '6', 'لامبوكا', '4', '20', '20', NULL, NULL, NULL, NULL, 0, 56, NULL, '2024-10-20 14:28', NULL, NULL, '2023-12-28 14:26', '0', NULL),
(45, 35, NULL, '57', '5bd6898649c4e840faddeb019e2e5fff.png', '2', '5', 'الحبار العادي', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 57, NULL, '2024-12-18 22:11', NULL, NULL, '2024-12-18 22:09', '0', NULL),
(47, 37, 5, '59', '70da58b5d2bc47ba83a156e655a2bf75.png', '2', '6', 'السريولا', '4', NULL, NULL, '30', NULL, NULL, NULL, 1, 59, 118, '2024-12-20 02:01', NULL, NULL, '2024-12-20 02:00', '0', NULL),
(48, 38, 5, '59', '63d572b6d79f39ce1018e51c22cf583c.png', '2', '6', 'السريولا', '4', '20', NULL, '310', '2024-02-19 16:25', NULL, NULL, 1, 59, 137, '2024-10-16 20:03', NULL, NULL, NULL, '0', 1),
(49, 39, NULL, '60', 'de7de83acf6a404eb1e141a0d0d17ed6.png', '1', '6', 'البوري', '4', NULL, NULL, '120', NULL, NULL, NULL, 1, 60, 118, '2024-12-20 13:49', NULL, NULL, '2024-12-20 13:48', '0', NULL),
(50, 40, NULL, '60', '94f13522e2e95fe2ab200ca588b3f48e.png', '1', '6', 'البوري', '4', NULL, NULL, '80', NULL, NULL, NULL, 1, 60, 118, '2024-12-20 14:17', NULL, NULL, '2024-12-20 14:15', '0', NULL),
(51, 41, NULL, '60', 'a0f9c3733943c96c887f4c52ed0903c7.png', '1', '6', 'البوري', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 60, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(52, 42, NULL, '62', '7e20618952c1cf2dcabcd151448da160.png', '1', '6', 'سمك الأبراميس', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 62, NULL, NULL, NULL, NULL, '2025-01-06 13:56', '0', NULL),
(53, 43, NULL, '63', 'b5f0023828dd403089ad1556406fc5b5.png', '1', '2', 'سمك رخامي', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 63, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(54, 44, NULL, '63', '8e4c1338e6c981aa81785650e476b7b8.png', '1', '2', 'سمك رخامي', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 63, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(55, 45, NULL, '65', 'eef79660d905539bf5970d6be16f51c5.png', '1', '1', 'الحبار العادي', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 65, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(56, 46, NULL, '66', '7da8af667b40c5a6c49f570b2630098b.png', '1', '5', 'أوراتا', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 66, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(57, 47, NULL, '66', 'e6142180e2df22b23e275f22ef77b48b.png', '1', '5', 'أوراتا', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 66, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(58, 48, NULL, '68', 'ca5d30719b7eb68df9e41b12c4c667d4.png', '1', '4', 'البوري', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 68, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(59, 49, NULL, '69', '316bd7e5fea37011cc97f167336ac3e5.png', '1', '2', 'البوري', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 69, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(60, 50, NULL, '70', '3cbe70efe003cbc6d0ab4a8936f277fb.png', '1', '2', 'أوراتا', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 70, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(61, 51, NULL, '71', '858122459cace911770dec318525d1ad.png', '1', '2', 'البوري', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 71, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(62, 52, NULL, '72', '07703002e17c00f870be2dd8fbf60437.png', '1', '2', 'البوري', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 72, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(63, 53, NULL, '74', '5c6caf14fea1a6baf4c8eedcce37b089.png', '1', '2', 'أوراتا', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 74, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(64, 54, NULL, '75', 'f254d8c6a77705b2fbc480787b6e8c41.png', '1', '2', 'ﺎﻴﻟﺮﺘﺳﺇ', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 75, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(65, 55, NULL, '76', '5a2be66df01eeb58d8be8c0e341a6e41.png', '1', '2', 'البوري', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 76, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(66, 56, NULL, '77', 'fdd1b5f81f4b7c2078315c6c13aad35e.png', '1', '2', 'ﺎﻴﻟﺮﺘﺳﺇ', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 77, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(67, 57, NULL, '78', 'eae78ca0116dd74dfe611fd5048eeb4b.png', '1', '2', 'الحبار العادي', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 78, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(68, 58, NULL, '79', '5a0dff3c62f9f854537a65975d4447cc.png', '1', '2', 'أسماك سوليولا', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 79, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(69, 59, NULL, '80', 'ab2705600d553085e945f26a24d3768d.png', '1', '3', 'الحبار العادي', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 80, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(70, 60, NULL, '81', '2ab4c072bf90193c10be7413995855a0.png', '1', '2', 'الحبار العادي', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 81, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(71, 61, NULL, '83', '49c37fce375f5e1336cc500509cdc3ea.png', '1', '4', 'الحبار العادي', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 83, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(72, 62, NULL, '84', 'e2d6113116c5dbc4cc5b2360e133ac96.png', '1', '5', 'البوري', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 84, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(75, 65, NULL, '87', 'c072601329f0cc72a924e01ab9834ea3.png', '122', '28', 'البحر سمك باس', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 87, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(76, 66, 2, '89', 'b93f3be5992c4a1e4221d5f801dd86a7.png', '99', '18', 'لامبوكا', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 89, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(77, 67, 5, '90', '07f5e750d7f92b425d4682c755fad2bd.png', '1234', '23', 'الجريث', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 90, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(78, 68, 2, '90', 'ce88e331795e612a75f3f25315b37e5e.png', '1234', '23', 'الجريث', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 90, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(79, 69, 5, '90', '8187a0aeb9367cd5ec1a82fdc6e888c5.png', '1234', '23', 'الجريث', '4', NULL, NULL, '30', NULL, NULL, NULL, 1, 90, 118, '2023-12-28 01:04', NULL, NULL, '2023-12-28 01:02', '0', NULL),
(80, 70, 5, '90', '12d26eed2547a27bf05dc927c12eb2f4.png', '1234', '23', 'الجريث', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 90, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(81, 71, 5, '91', 'c132be102933287a99202749d17edd54.png', '20', '20', 'أخطبوط', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 91, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(82, 72, 5, '91', '1aa4a9f88f90ddb7874107b8a52a70ee.png', '20', '20', 'أخطبوط', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 91, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(83, 73, 2, '91', 'e703a56a9d2d9fb6a8ee61b51b0f40d3.png', '20', '20', 'أخطبوط', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 91, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(84, 74, 2, '92', '7c7f7e3f4ec55cb342072ad9df5378c7.png', '90', '90', 'البحر أسماك', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 92, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(85, 75, 2, '93', '0d60053be8b7b2642bbb303917c069d3.png', '120', '900', 'أوراتا', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 93, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(86, 76, 5, '94', '2aa405d245fcadc5549fcea6cba2b416.png', '23', '80', 'البوري', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 94, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(87, 77, 2, '95', 'c107561823a16776f7fed3659b92fd0e.png', '102', '102', 'الحبار العادي', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 95, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(88, 78, 2, '98', 'bc6d792b6899bd9786c8fd5f1ffc399e.png', '12', '12', 'سوبيا ', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 98, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(89, 79, 2, '99', 'fcc230ac1accb342a909ce51f8d94679.png', '1', '3', 'الحبار العادي', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 99, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(90, 80, 2, '100', '265dc4b0b20f2dae037817817a07b869.png', '1', '2', 'سوبيا ', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 100, NULL, NULL, NULL, NULL, NULL, '0', NULL),
(91, 81, 2, '101', '7ab0810150e39ed775dbf76010240f2e.png', '1', '1', 'أوراتا', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 101, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(92, 82, 2, '103', 'cfb5a402959e827d13b2e306197b9060.png', '1', '2', 'سوبيا ', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 103, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(93, 83, 5, '104', '3f3d38fae414ce2a501fa5579c21c7dc.png', '1', '2', 'تريليا ', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 104, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(94, 84, 2, '105', 'f852095a055d2a699071df49d03e23f1.png', '1', '1', 'سوبيا ', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 105, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(95, 85, 5, '106', '6ccc208430fb0912dad78da8dda7b08b.png', '1', '1', 'أوراتا', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 106, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(96, 86, 2, '107', 'b05b6d48a63340a98aec77a368d7c625.png', '1', '1', 'سوبيا ', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 107, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(97, 87, 2, '108', '96218f42f57bd7144989b883f855f793.png', '2', '2', 'أوراتا', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 108, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(99, 89, 2, '109', 'bc6d792b6899bd9786c8fd5f1ffc399e.png', '', '3', 'سوبيا ', '4', NULL, NULL, NULL, NULL, NULL, NULL, 0, 109, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(100, 90, 2, '113', 'bc6d792b6899bd9786c8fd5f1ffc399e.png', '1', '2', 'سوبيا ', '4', NULL, NULL, NULL, '2024-12-19 04:30', NULL, NULL, 0, 113, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(101, 91, 2, '114', '7ab0810150e39ed775dbf76010240f2e.png', '1', '2', 'أوراتا', '4', NULL, NULL, NULL, '2024-12-19 05:30', NULL, NULL, 0, 114, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(102, 92, 2, '115', 'bc6d792b6899bd9786c8fd5f1ffc399e.png', '1', '2', 'سوبيا ', '4', NULL, NULL, NULL, '2024-12-19 17:26', NULL, NULL, 0, 115, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(103, 93, 2, '116', 'bc6d792b6899bd9786c8fd5f1ffc399e.png', '1', '2', 'سوبيا ', '4', NULL, NULL, NULL, '2024-12-19 05:45', NULL, NULL, 0, 116, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(104, 94, 5, '117', 'bc6d792b6899bd9786c8fd5f1ffc399e.png', '1', '2', 'سوبيا ', '4', NULL, NULL, NULL, '2024-12-19 13:28', NULL, NULL, 0, 117, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(105, 95, 5, '118', '3f3d38fae414ce2a501fa5579c21c7dc.png', '1', '5', 'تريليا ', '4', NULL, NULL, NULL, '2024-12-19 05:30', NULL, NULL, 0, 118, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(106, 96, 5, '118', '3f3d38fae414ce2a501fa5579c21c7dc.png', '1', '5', 'تريليا ', '4', NULL, NULL, NULL, '2024-12-19 06:28', NULL, NULL, 0, 118, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(107, 97, 2, '119', 'c107561823a16776f7fed3659b92fd0e.png', '2', '5', 'الحبار العادي', '4', NULL, NULL, NULL, '2024-12-19 13:28', NULL, NULL, 0, 119, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(108, 98, 5, '120', 'bc6d792b6899bd9786c8fd5f1ffc399e.png', '6', '5', 'سوبيا ', '4', NULL, NULL, NULL, '2024-12-19 14:28', NULL, NULL, 0, 120, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(109, 99, 5, '121', 'bc6d792b6899bd9786c8fd5f1ffc399e.png', '1', '2', 'سوبيا ', '4', NULL, NULL, '60', '2024-01-17 13:28', NULL, NULL, 1, 121, 118, '2025-02-05 04:26', NULL, NULL, '2025-02-05 04:24', '0', NULL),
(110, 100, 5, '122', '3f3d38fae414ce2a501fa5579c21c7dc.png', '3', '5', 'تريليا ', '4', NULL, NULL, '20', '2024-01-19 13:28', NULL, NULL, 1, 122, 118, '2025-02-05 04:17', NULL, NULL, '2025-02-05 04:15', '0', NULL),
(111, 101, 5, '123', 'bc6d792b6899bd9786c8fd5f1ffc399e.png', '2', '6', 'سوبيا ', '4', NULL, NULL, '50', '2024-01-21 13:28', NULL, NULL, 1, 123, 118, '2025-02-04 13:29', NULL, NULL, '2025-02-04 13:31', '0', NULL),
(112, 102, 5, '124', 'e2d6113116c5dbc4cc5b2360e133ac96.png', '1', '9', 'البوري', '4', NULL, NULL, '20', '2024-01-23 13:28', NULL, NULL, 1, 124, 118, '2025-02-03 02:24', NULL, NULL, '2025-02-03 02:23', '0', NULL),
(113, 103, 2, '125', 'bc6d792b6899bd9786c8fd5f1ffc399e.png', '2', '8', 'سوبيا ', '4', NULL, NULL, '30', '2024-01-24 13:28', NULL, NULL, 1, 125, 118, '2025-01-15 15:53', NULL, NULL, '2025-01-15 15:51', '0', NULL),
(114, 104, 2, '126', '2aa405d245fcadc5549fcea6cba2b416.png', '2', '5', 'البوري', '4', NULL, NULL, '50', '2024-01-26 13:28', NULL, NULL, 1, 126, 118, '2025-01-15 11:10', NULL, NULL, '2025-01-15 11:08', '0', NULL),
(115, 105, 2, '127', 'c107561823a16776f7fed3659b92fd0e.png', '2', '6', 'سوبيا ', '4', NULL, NULL, '20', '2024-01-27 13:28', NULL, NULL, 1, 127, 118, '2025-01-15 11:06', NULL, NULL, '2025-01-15 11:05', '0', NULL),
(116, 106, 2, '128', 'c107561823a16776f7fed3659b92fd0e.png', '2', '5', 'سوبيا ', '4', NULL, NULL, '13.5', '2024-01-29 13:28', NULL, NULL, 1, 128, 118, '2025-01-15 01:44', NULL, NULL, '2025-01-15 01:43', '0', NULL),
(117, 107, 2, '130', '7c7f7e3f4ec55cb342072ad9df5378c7.png', '3', '8', 'مخلط ', '4', NULL, NULL, '40', '2024-01-22 13:28', NULL, NULL, 1, 130, 137, '2025-01-15 01:25', NULL, NULL, '2025-01-15 01:24', '0', NULL),
(118, 108, 2, '131', '07703002e17c00f870be2dd8fbf60437.png', '3', '7', 'مخلط ', '4', NULL, NULL, '50', '2024-01-24 13:28', NULL, NULL, 1, 131, 137, '2025-01-14 17:22', NULL, NULL, '2025-01-14 17:21', '0', NULL),
(119, 109, 2, '134', '96218f42f57bd7144989b883f855f793.png', '10', '02', 'الماكريل الحصان', '4', NULL, NULL, '150', '2024-01-27 13:28', NULL, NULL, 1, 134, 137, '2025-01-14 16:21', NULL, NULL, '2025-01-14 16:21', '0', NULL),
(121, 113, 2, '140', 'c107561823a16776f7fed3659b92fd0e.png', '22', '20', 'تريليا ', '4', '20', '', '50', '2024-12-19 13:28', 1, NULL, 1, 140, 137, '2024-12-19 13:37', NULL, 'asc', '2024-12-19 13:36', '0', NULL),
(124, 116, 2, '143', '5859634add14629c3223cf06956a2c24.png', '1', '1', 'روبيان بالكراموت', '7', '20', '', '40', '2025-02-05 11:07', 1, NULL, 1, 141, 134, '2025-02-07 09:03', NULL, 'asc', '2025-02-07 09:02', '0', NULL),
(126, 118, 2, '144', '13d736c8c3a72765378ae85e6710d7d0.png', '1', '4', 'أوراتا', '7', '6', '', '55', '2025-02-05 12:15', 1, NULL, 1, 144, 137, '2025-02-05 11:45', NULL, 'asc', '2025-02-05 11:43', '0', NULL),
(127, 119, 2, '145', '544b27b07c3521f5af55702c18a24491.png', '3', '20', 'أوراتا', '7', '20', NULL, NULL, '2025-02-05 12:24', 1, NULL, 0, 144, NULL, '2025-02-11 11:00', NULL, NULL, '2025-02-11 10:59', '0', NULL),
(128, 120, 2, '146', '8e244e984b01bde32024239c24b2ea43.png', '2', '22', 'أوراتا', '7', '20', '', '12', '2025-02-05 12:28', 1, NULL, 1, 146, 137, '2025-02-05 12:40', NULL, 'asc', '2025-02-05 12:37', '0', NULL),
(129, 121, 2, '147', '03560b6788eaeb0581a665142a1b1141.png', '10', '20', 'البوري', '7', NULL, NULL, '127', '2025-02-10 16:25', 1, NULL, 1, 147, 137, '2025-02-05 12:52', NULL, NULL, '2025-02-05 12:50', '0', NULL),
(130, 122, 2, '147', '58c68679ff3d12527a2f6872ef540dba.png', '10', '20', 'البوري', '7', '20', '', '3333', NULL, 1, NULL, 1, 147, 37, '2025-02-05 12:46', NULL, 'asc', '2025-02-05 12:44', '0', NULL),
(131, 123, 2, '149', 'b6d1bb28f79ee08eeb447fbdd2294e17.png', '20', '10', 'قرنيط', '7', NULL, '', '33', '2025-02-10 16:37', 1, NULL, 1, 149, 134, '2025-02-11 01:54', NULL, 'asc', '2025-02-11 01:52', '0', NULL),
(132, 124, 2, '150', '61a5665d5221f9cf6499a11a46935bac.png', '20', '20', 'كلمار', '7', '20', '', '70', '2025-02-10 16:45', 1, NULL, 1, 150, 134, '2025-02-10 16:48', NULL, 'asc', '2025-02-10 16:45:56', '0', NULL),
(133, 125, 2, '151', 'b3502fbc644418a879be04ef5785666a.png', '1', '8', 'لنقوسطة', '7', '20', '', '45', '2025-02-11 11:17', 1, NULL, 1, 151, 134, '2025-02-11 11:29', NULL, 'asc', '2025-02-11 11:27:59', '0', NULL),
(134, 126, 2, '152', '76d3f3a9600db93181e24f7541ea5d9a.png', '2', '24', 'سوبيا', '7', '18', '', NULL, '2025-02-19 13:51', 1, NULL, 0, 152, NULL, NULL, NULL, 'asc', '2025-02-11 11:35:28', '0', NULL),
(135, 127, 2, '154', '6cce442a307e2315c8efb6be3814f713.png', '3', '32', 'تريلية حمراء', '7', NULL, NULL, NULL, '2025-02-11 11:41', 1, NULL, 0, 154, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(136, 128, 2, '155', '990dbd0dfdb46f57921ca2c643502105.png', '1', '20', 'كلمار', '7', NULL, NULL, NULL, '2025-02-11 11:45', 1, NULL, 0, 155, NULL, NULL, NULL, NULL, '2025-02-13 15:22', '0', NULL),
(137, 129, 2, '156', '3d6b8dacd1c67754864aff9be756249a.png', '2', '2', 'كلمار', '7', NULL, NULL, NULL, '2025-02-11 11:50', 1, NULL, 0, 156, NULL, NULL, NULL, NULL, '2025-02-18 09:25', '0', NULL),
(139, 130, 2, '157', '71c1619bb7457b7959bdcf728baac675.png', '1', '2', 'بومسك', '7', NULL, NULL, NULL, '2025-02-19 14:03', 0, NULL, 0, 157, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(140, 131, 2, '158', '5c54cfa8d053e53648c5a4373ccd7436.png', '1', '2', 'مرجان', '7', NULL, NULL, NULL, '2025-02-19 14:15', 0, NULL, 0, 158, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(141, 132, 2, '159', '289337f6083ad577e8ddcce9d03d4561.png', '2', '2', 'كلمار', '7', '100', '', '120', '2025-02-19 14:20', 1, NULL, 1, 159, 137, '2025-02-19 14:26', NULL, 'asc', '2025-02-19 14:24:11', '0', NULL),
(142, 133, 2, '160', '77d492297842a71dfde576991262aa80.png', '1', '2', 'قرنيط', '7', NULL, NULL, NULL, '2025-02-19 16:20', 0, NULL, 0, 160, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(143, 134, 2, '161', '97e9df3af4eca5dd6c9c04eea912c55c.png', '1', '2', 'سوبيا', '7', '20', '', NULL, '2025-02-19 16:25', 1, NULL, 0, 161, NULL, NULL, NULL, 'asc', '2025-02-19 16:26:52', '0', NULL),
(144, 135, NULL, '162', '946d83fc1640c185720b2fd53b992b33.png', '3', '20', 'كلمار', '7', NULL, NULL, NULL, NULL, NULL, NULL, 0, 162, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(145, 136, NULL, '162', '3396b1ff2e8c293326738f27703d429c.png', '3', '20', 'كلمار', '7', NULL, NULL, NULL, NULL, NULL, NULL, 0, 162, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(146, 137, 2, '163', '62248339d99e9346ac73005221743068.png', '1', '10', 'قمبري ملكي', '7', '20', '', '30', '2025-02-20 11:44', 1, NULL, 1, 163, 137, '2025-02-20 11:53', NULL, 'asc', '2025-02-20 11:52:06', '0', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_maryeur`
--

CREATE TABLE `marketplace_maryeur` (
  `id` int NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `roles` json NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `nom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `prenom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `cin` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `matricule` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `port` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pays` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `wallet` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `mykeyss` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `telephone` int DEFAULT NULL,
  `is_valid` tinyint(1) NOT NULL,
  `signature` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_maryeur`
--

INSERT INTO `marketplace_maryeur` (`id`, `email`, `roles`, `password`, `nom`, `prenom`, `cin`, `matricule`, `port`, `pays`, `wallet`, `mykeyss`, `telephone`, `is_valid`, `signature`) VALUES
(2, 'alayethoussem2@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$NlptVXczWUl6bkNudmd5ZA$7Rf4Osln5hpby8cfWPuXcVQGbJ02OFJTQP3ou9dXXds', 'ti', 'ti', '07961760', '123345', NULL, NULL, '0x33AC1d2f41aF63Fe4B52c8Ae266Df89A38EE534a', '0xe451fc918141fccbfb365f1ec636b4b3d46c9059b9dbda808a7bd688d157372e', 9458648, 1, 'signature-mareyeur01.png'),
(3, 'hama@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$seA9WI54mdDn0iiEWqjJkg$ZTLZ7taZ248FBo8HmxrXFIcYdDwXQMVFo+OnOSzMzdU', 'hama', 'hamoush', '13098715', '123456', NULL, NULL, '0x33AC1d2f41aF63Fe4B52c8Ae266Df89A38EE534a', '0xe451fc918141fccbfb365f1ec636b4b3d46c9059b9dbda808a7bd688d157372e', 29082245, 1, 'signature-mareyeur01.png'),
(4, 'mohamedmar@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$VNFhaENiH40qL5CFZTyYkw$pmVS7eakx67TDVsMNJWo0csRQgUEOVT9jB2rf6MwoZk', 'Ahmed Maryeur', 'bel arbi', '11223344', 'DDR42', NULL, NULL, '0x1f5c0dae2c1601e7eb22be0a677013a699127326', '0x2bbda4790bbe3b69a8ab2c77e6fe43f28dfe33a2deb0e27ae912c99609773b2e', 12345678, 1, 'signature-mareyeur01.png');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_message`
--

CREATE TABLE `marketplace_message` (
  `id` int NOT NULL,
  `sender_id` int DEFAULT NULL,
  `receiver_id` int DEFAULT NULL,
  `message` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `date` datetime NOT NULL,
  `readed` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_message`
--

INSERT INTO `marketplace_message` (`id`, `sender_id`, `receiver_id`, `message`, `date`, `readed`) VALUES
(86, 137, 37, 'test', '2022-12-19 15:19:10', 1),
(87, 37, 137, 'bonjour.................................................................................NICE', '2022-12-19 15:20:13', 0),
(119, 37, 137, 'hi', '2025-04-04 11:30:27', 0);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_panier`
--

CREATE TABLE `marketplace_panier` (
  `id` int NOT NULL,
  `produit_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `quantite` int NOT NULL,
  `created_at` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_panier`
--

INSERT INTO `marketplace_panier` (`id`, `produit_id`, `user_id`, `quantite`, `created_at`) VALUES
(7, 25, 37, 2, '2025-04-04 11:32:09');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_panier_equipement`
--

CREATE TABLE `marketplace_panier_equipement` (
  `id` int NOT NULL,
  `equipement_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `quantite` int NOT NULL,
  `created_at` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_pecheur`
--

CREATE TABLE `marketplace_pecheur` (
  `id` int NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `roles` json NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `nom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `prenom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `cin` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `matricule` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `capacite` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `longeur` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `largeur` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `bateau` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `pays` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `proprietaire` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `serie` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `certification` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `port` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `engin` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `wallet` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `mykeyss` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `telephone` int DEFAULT NULL,
  `is_valid` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_pecheur`
--

INSERT INTO `marketplace_pecheur` (`id`, `email`, `roles`, `password`, `nom`, `prenom`, `cin`, `matricule`, `capacite`, `longeur`, `largeur`, `bateau`, `pays`, `proprietaire`, `serie`, `certification`, `port`, `engin`, `wallet`, `mykeyss`, `telephone`, `is_valid`) VALUES
(2, 'houssemalayet17@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$cDA3QTBqMjI4RlhvY1psUg$zNeUeDbO4PLTL3ecfJZgocU3ntoDT1B0qgdsBR4Fjoc', 'houssem', 'alayet', '07961760', '123345', '10TONNES', '255', '23', 'lA LUNA', 'Tunis', 'houssem', '1233345', '-', 'Zarzouna', 'Fillet', '0xF52bAAf3a8506C60bC63fF83ba5F685585886Da2', '0x2cf0e53ea03750de28fc00888092978b1a3abc5016dc1ca23d2145a6120dbf7a', 94586480, 1),
(27, 'jabriskander361@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$obl35pTP/cZouHMQSLprjQ$kgtrhPQzdj0W7U5HiRSdxLCAy2ipATIi7ftHan3YwTs', 'iskander', 'jabri', '130252978', '123Tun4025', '10THONS', '78', '125', 'skypeche', 'Tunisie', 'SKY', '147', 'BIEN', 'ZARZOUNA', 'EN1', '0xF52bAAf3a8506C60bC63fF83ba5F685585886Da2', '0x2cf0e53ea03750de28fc00888092978b1a3abc5016dc1ca23d2145a6120dbf7a', 27410023, 1),
(28, 'alayethoussem7@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$D2+JFFhV9OXqBniN+Zo+xQ$EHNf7BsXjnuNbvn2tVq8GsDR8iWgDi0iz8HYXxsRIVw', 'houssem', 'alayat', '14785236', '13025GN', '2thon', '12', '10', 'skymarie', 'Tunis ', 'HOUSS', '1234', 'BIEN ', 'ZARZOUNA', 'EN1', '0xF52bAAf3a8506C60bC63fF83ba5F685585886Da2', '0x2cf0e53ea03750de28fc00888092978b1a3abc5016dc1ca23d2145a6120dbf7a', 27896541, 1),
(29, 'mouhamedSdouga@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$ZPAdQwxhZgxoTELuFgtlsA$Y4bPXbjb+NZZN7krWlg9sIAjcx2tWNde7RS07dJJRmk', 'mohamed', 'sdouga', '12302547', '12utn147', '14 thon', '44', '944', 'x1', 'tunisie', '14', '123456', 'bien ', 'zarzouna', 'e1', '0xF52bAAf3a8506C60bC63fF83ba5F685585886Da2', '0x2cf0e53ea03750de28fc00888092978b1a3abc5016dc1ca23d2145a6120dbf7a', 27896855, 1),
(30, 'jabriskander377761@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$B4m7f+ZelLWuMmgEd6ZDow$G9U+oOjTIeYlJ49t0W465v3NDY5MMkH7v8HGd9Vz+7E', 'hama', 'hama', '13098715', '123456', '950 kg', '10', '8', 'skypeche', 'Tunis', 'skon', '1233345', 'test', 'zarzouza', 'Engin1', '0xF52bAAf3a8506C60bC63fF83ba5F685585886Da2', '0x2cf0e53ea03750de28fc00888092978b1a3abc5016dc1ca23d2145a6120dbf7a', 29082245, 1),
(31, 'mohamedpech@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$Cd0JGJxPiqC+ojTouPX9Zg$dcUxr6JyobYQxcll2IQX74KpEQVTQKnO3O6nTaIRPVE', 'mohamed Pecheur', 'bel arbi', '11223344', '12FRZ', '19thon', '6m', '2m', 'Hayet1232', 'Tunis', 'prop1', '11tn1233', 'Bien', 'Zarzouna', 'mohamed Pecheur', '0x0383ba13833067f00d64ecd497ea374e8bd917e9', '0xcacc2e8b1f0d2e7823f97cde22e79a51bb18b8351f43bbbb14e69331e96df27f', 12345678, 1),
(32, 'abderraoufchaaben@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$ue7FX03DJHAZMamSVFivtg$Ou8cqCCyHCib9h+JATRTiC4Pfr0GHJ/DuNu5e4nwSGs', 'Chaaben', 'Abderraouf', '', '', '', '5.3', '', 'Mariem', '', '', '6722BI', '', '', '', '0x3874c56a59864eAdbe26359740d011f8475bfa7b', '0x85f305d38288ed591184bcc30119ea9ec92369081ae746803723e03507092981', 98948433, 1),
(33, 'youssefraouafi@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$s5rIe4olGzF1cPWX3Ir8cQ$dz+grNKLDeBHGqtp4oOwvEDe/svDZvJw/v8Uwz2ZDNA', 'Raouafi', 'Youssef', '', '', '', '4.7', '', 'Tounes Elkhadhra', '', '', '1927BI', '', 'Raouafi', 'Raouafi', '0x3475938C15cC82E931b25DB86C5d1E26D4dbc0b5', '0xfd70d841661aa4af066f17a24f3f74271e870658333b65511c59dcb0bd01bb6f', 12345678, 1),
(34, 'mohameddahech@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$biurkVfpFHhUFdko0QLGSg$3D8IIS+BM7MtD0N3qepOJ1Gd+mARFtxGTRUNKWHq76E', 'Dahech', 'Mohamed', '', '', '', '4.3', '', 'Majd', '', '', '5527BI', '', '', '', '0xB78d5b7987458ff6e0fb1981aeaeF7AD66DEDb2B', '0x499fa9bd0c5968a7056cd23bd6fe3fe2479e61b4a4c69f77330c020f34fd833e', 12345678, 1),
(35, 'mehdi.tabbakh@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$q0Cb0SUFncZ3qZqSyaIAIw$Dcw1VhnlZ7ZHG7DdNAeTZkaUge4AUfmrGwkkWWBMKAI', 'Tabbakh', 'Mohamed Mehdi', '04702616', 'BI2601', '', '4.1', '1.5', 'Baya', 'Tunis', 'محمد.مهدي الطباخ', '2601BI', '', 'Zarzouna', 'مجموعة شباك خيشومية للعينات والسردين والبوري والصوبات الزراعية', '0x085EF27EC7b9E711C47DC79efED8840feb6C2611', '0x8d313fd68e0f79179849ce8bae2d056f45b1708211dd19c4c35385aeafa59930', 97548903, 1),
(36, 'riadhkhalifa@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$xHWydlRpT02znEFm03ZHxw$1betWWucNTTeetk2NXO5f9mxIKOcWSk/mtNguvCGPis', 'Khalifa', 'Riadh', '', '', '', '3.9', '', 'Mohamed', '', '', '3360BI', '', '', '', '0xDd7BF85c9CDc5c982f5fe6d3300D522DeF3dAA01', '0x1fcbe7a02c2d3193718726bebc30f082fbde8c03931782569dfb5fe63bb73b2a', 12345678, 1),
(37, 'makhloufhabib@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$ALYK2XjeVVReKihfLwHgEQ$EI56IdYcMT+gIqXxUkc2v80ITNRd0kC0k+jVEhQwmRs', 'Makhlouf', 'Habib', '', '', '', '3.8', '', 'Assil', '', '', '5808BI', '', '', '', '0x4308056e75E4e175C0F0158C91f77A5Ab1e505e3', '0xfb82c53051b070014809c75706af854762259ff491cc48b8e129830703778e05', 12345678, 1),
(38, 'raouafibechir@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$2DiIwh79WlzA3n47PawQdA$u/v83Xw9aleFgy7G03jzCEzUxvIX5KIPW8rVIe3AAuc', 'Raouafi', 'Bechir', '', '', '', '3.7', '', 'Nouba', '', '', '5785BI', '', '', '', '0x31D06E9F716B484988ed45905F714dF756E9f616', '0xa6838214775c54e53b2977900d0e8df03afa33264c6b43a0625d22150859a5a9', 12345678, 1),
(39, 'lachalomar@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$MIiSEpK4n4mcDvzZ1d/MbQ$lEg1gHrU7PeroBnBCnnA0q8Q8W30QeLA/fE5gV44YLc', 'lachaal', 'Omar', '', '', '', '3.7', '', 'Houda', '', '', '5330BI', '', '', '', '0xA2fd7A915B800F0c7456E1034408f0f2bE945e9b', '0xeae819aa4453ebe9945943c1d78b9061a9b7961a2869882e4f3d7479f4a2e3ab', 12345678, 1),
(40, 'abidihosni@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$tEam9sia1Z/XFosA7J1sdQ$TFqzzdtRBAiLrNemfM35FMrid3Za3/plqIBeWGqfYOU', 'Abidi', 'Hosni', '', '', '', '3.6', '', 'Farah', '', '', '6060BI', '', '', '', '0x6EF5D5C86a54cFE77Ff9F93E1078605d142274bF', '0x2d58e3dd5531a388cc4a882e91c514cd171f016ac85526aeb175ad4e2c2d8170', 12345678, 1),
(41, 'noamenhaithem@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$yt5kmCeU/3PjvLJFsZ5oXA$mOqRXrbSLlSm3jLR0pq+w+Ljxp8Uf5Za6OkRDDHCsLQ', 'Noamen', 'Haithem', '', '', '', '3.5', '', 'Emna', '', '', '5889BI', '', '', '', '0x24475F3b9e70b5D31217f225A9e97B680Ffb41d5', '0x8955e5d326f750759c4466e82a382b02dd398ca5bdc1cdd2a8995b455e95b86f', 12345678, 1),
(42, 'shaiekmouhamed@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$bn77AOu45MojQH0jiFJFbQ$xwK1Llrtwpy9jjW8N1UO2KBNP1cdyXLhm41tEMgb734', 'Shaiek', 'Mouhamed Ali', '', '', '', '7.6', '', 'NAWAL', '', '', '2592BI', '', '', '', '0xd401ED859b10DE8Ef1cEDdDC7A36e4A630aC6F10', '0xe0da0b6eee917e3e89898dc84d8f6838f5521a1347f34ffa28cfd72c99058b9a', 12345678, 1),
(43, 'ettaiebsaddem@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$wKWhjcmbrk/Z8SMiTD7L7w$aH5UkMmqR0X0/iNc56YJOsrw2Cr2EsxTUfx8EIvDulc', 'Rejeb Ettaieb', 'Saddem', '', '', '', '7.6', '', 'Mahbouba', '', '', '6641BI', '', '', '', '0x4826c5DfF9518e145eDAA26a89341577653b7f9A', '0xd3afb213fdf00666c7e7f023b7a8cc00add5926108517fa75ef57abc52cf23f1', 12345678, 1),
(44, 'bensabertarek@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$y/h34d/9uHBmvErzd7n7tw$jwmB8JqELWFnX353fY8GTFvBrnuhL9g2alX4pkIVhnw', 'Ben Saber', 'Tarek', '', '', '', '7.6', '', 'Saida', '', '', '2649BI', '', '', '', '0xD3d6d46Fe9Ad0C60E7BC1D2b5ca6096C55C71b8C', '0xf41a1d988bc68e7340841bb511c18e1020355ac3af370e101afc5a848361eb4a', 12345678, 1),
(45, 'hachanihassoun@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$OWt+XvjQJ+wNzuh1Anr2NQ$3C0Rmc8FfLaKTivmtQjI4tF98t9/ll56XVjtlYWh+0I', 'Hachani', 'Hassoun', '', '', '', '7.6', '', 'Chikly', '', '', '6091BI', '', '', '', '0x78F57F65Cb49CE75b0D658D712e5E31912388051', '0x5787770afd52db8c5209b5a24e2223a80fb0a573ebe9c4a51b645dac8b2f792c', 12345678, 1),
(46, 'zouaouihassen@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$ydJm4PWLISwGldsZCaxTiA$qV4cLq4t3HDs0vAr5lb2/GTeGiYfKQea11ZDVdQyD4I', 'Hassen', 'Zouaoui', '05675538', '3821', '2.71ton', '8.17\n8\n8.17', '2.6', 'Farida', 'Tunis', 'Hassen', '3821BI', '', 'Manzel abd rahmen', 'شباك القاع الثابتة', '0x287055a181aAFA33B0aAf0AE43588758862B38E4', '0xe36cfed18accba895ec69af892ad18cb1e22b155ed4c21944068deea181fad68', 92505968, 1),
(47, 'makhloufmajdi@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$Q3M6+XDsZIct1F0sJDG9kg$r1b1zz9yFN84+o7xT1aNMWg2325TSg6Cl9YPk8bx9wo', 'Makhlouf', 'Majdi', '', '', '', '7.6', '', 'Ratiba', '', '', '2477BI', '', '', '', '0xB8D132A44fd410DC99FABa90200A6593c6C13870', '0xeca31eb2be8b5f0c315296f4375f9e6062162029c3c840bd227d5be2dc7ba360', 12345678, 1),
(48, 'garanebil@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$KuCKXCJcfo65fKjOJveXOg$er+sWuqHO4HNsX3tVzJdEGX2rEU9YsC+JjAdfqvIoDM', 'Gara Ali', 'Nebil', '', '', '', '7.6', '', 'Israa', '', '', '6371BI', '', '', '', '0x687BC96457777ef5132B5a0271e6D8067217AD90', '0xa45008d90fbca28008081ae485751b3001c0a480deee4c8b36d8115817302899', 12345678, 1),
(49, 'boussandeldhaoui@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$Ucl//RynMulPWiUF5rKQQw$6PchKcM+DXAqXu8RK+jy9XwJ2mQgA0xhUc3VS1p5U0A', 'Boussandel', 'Dhaoui', '', '', '', '7.6', '', 'Najeh', '', '', '1614BI', '', '', '', '0x9f724Efa5541FBE6F22718D50C8a62daE59c82Cb', '0xe30eec18a61b979d75a2e0180ddd420e2e13abb15017f7e855401281ec5aca9f', 12345678, 1),
(50, 'benrhoumalotfi@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$6k4BCQcF640MESqZJ/nfrA$dDW7mwcfvVjVOTkIn15ePPuN/s0EkOyt/AjMGQQX/3c', 'Ben Rhouma', 'Lotfi', '', '', '', '7.6', '', 'Mabrouka', '', '', '3511BI', '', '', '', '0xCfcA43f4194fDD2ba9306C2b8DeBf1cD30e838fd', '0x59ddd415a68251b32a067a36c502bce5ca82686b221d552c7a0dd123df1946f0', 12345678, 1),
(51, 'bekirmouhamed@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$pOHCjpw4jk6jZJsuAe2mCQ$SArOgaZxL7wFMqqLUJbR93RCDWX88jFpXsFimLH2cSc', 'Bekir', 'Mouhamed', '', '', '', '7.6', '', 'Sabrine', '', '', '4026BI', '', '', '', '0xe49a4992ADCa3e6EfBda2b7bfDAB5557293af5f3', '0x1e6647177aedea8f8084a8ea3198b1fa96aa968a7b14717e8a303aaec91e12e5', 12345678, 1),
(52, 'hachenibilel@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$HsHklCdaIbTjx5QV8Np50w$k0+nsSycmdZaTY2W5qy3MSxdbG4qz24SyKMR2YPCY64', 'Hacheni', 'Bilel', '08918997', '', '', '6.9', '', 'Hiba', '', '', '2360BI', '', 'Hacheni', 'Hacheni', '0x9FCC04c587f4E8FE8F3Cb62D64A21112D09f0FBE', '0x411246a4d7ff997687470f1906c0fbcbef4829ef5b6ab53369d32fea7e5bd4c5', 96378286, 1),
(53, 'ettaiebmouhamed@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$kWadveqOhyh4gbk6xUjnUg$dJWyPrI2qGApCwoT2TWXHxhFjkZN6JBCH01qcwogUu0', 'Rejeb Ettaieb', 'Mouhamed', '', '', '', '7.6', '', 'Oswa', '', '', '3464BI', '', '', '', '0xA08803bccECD6A862AaED1DfcfEc1A464BCaFA6D', '0xb7f5497dae1cf4cdcef10bf4b0067c925f116cc0e0bea861f24a19159a656808', 12345678, 1),
(54, 'boukoumhaikel@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$ft5SRu6o4jt/8NoumG0ocA$5OMU37iMGiyOxn9OBCtg1FdEBFTzkeDUj7FK3wXu+a8', 'Boukoum', 'Haikel', '08399978', '3238 BI', '2,05', '5,98', '\n2,30', 'Awda', 'Tunis', 'Haikel Boukoum', '3238BI', '', 'Boukoum', 'Boukoum', '0x442D72D49B6E1674807C5dF61151Fd782630869b', '0xa42167e1120a314504695c3f5d32a2ffa8034f65607f2ea9eba184e44dc6e6a6', 22194722, 1),
(55, 'sghaiersaouzi@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$Jd9At7HV8/R+40N91IpuOw$4OiYne8+e8Cvrstom2q59qmMA+0vMjIQ6HJzcFcNTSI', 'Sghaier', 'Faouzi', '', '', '', '7.6', '', 'Israa', '', '', 'MA3474', '', '', '', '0x148D2Aa2D001Eef634870E351fF52c0a2617c4E8', '0x5f4ebeeda4bb74e8829b01c9f8531a0faf4d1736f02329cf6220e15a27ae79d1', 12345678, 1),
(56, 'benazouzhedi@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$wMsV71DTYUP2z81Er+JRBg$HAinkydKosWZbFYQoHm8wUcErXSFHN05PYWkQeWe8S0', 'Ben Azzouz', 'Hedi', '', '', '', '7.6', '', 'Asma', '', '', '6444BI', '', '', '', '0x5BC13689dCfeB89ecD7064C053A04c53C188A11c', '0x36ca05e6b7e33cb822f1efbd4c99d8059de5376f6f3757349030d9220b169865', 12345678, 1),
(57, 'boussandelthaoui@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$Zf4PP8o0jzDvOW4ZYLQm0g$CDtO2h9e7kfW11XTU+jXPJYshnTEJFgfvQZUIBiCzfQ', 'Boussandel', 'Thaoui', '08386582', '', '', '7.38', '', 'Najeh', '', '', '1614BI', '', 'Boussandel', 'Boussandel', '0x9b50E515049214790Fd902e25B1815519f191ea6', '0x25ca5a9e5b9ffa7891f4cd4be1dcd3112dbbf6b00eb8484a38deda9717efe3fb', 96189143, 1),
(58, 'hbibsaidani@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$2u7V7aG6kJNJg6sBJmNVoA$PmTRWbsbhMY8bwrarb96JYzUBeBmZXqrdk2Uhso4Uno', 'hbib', 'saidani', '', '', '', '5.4', '', 'Ramla', '', '', '5836BI', '', '', '', '0x4a3d066673055e75b87c3009c7a0b132185c1bb696317ffa9ea91c6046c103e7', '0x6BA6103813f6af8e5b4401eB1B1872a2590ec44B', 56128188, 1),
(59, 'bilelferchichi@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$FhjPd6i9izOz+lqbu4UUCA$g9jsn6L4dyi1xSPxSvW0wKTlxuxWLbwaB23/y7Nx+tA', 'Bilel', 'Ferchichi', '', '', '', '4', '', 'Hlima', '', '', '2340BI', '', '', '', '0xe22e36eaf37125178d89b35857a5c61a05b3cec6c310d44c99c0a9f4b4bc850a', '0x83013f2c2417c57aA552613d2a0E9a275A6e371C', 20648417, 1),
(60, 'mohamedguesmi@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$uoyaVZyidly9elJ0f9vAIQ$pXgdgbCI/o4hWJ1svl76lPnCJskJOqC//2l5+aE4N9E', 'Mohamed', 'Guesmi', '', '', '', '4', '', 'Rames', '', '', '5170BI', '', '', '', '0xc7ae5bd48a23d3818c3a977916d39accf8615bf56c0c3fa33929269123ce458b', '0xfbd60af3A741F0110aA20a336fB9e487bc368Aa3', 21744743, 1),
(62, 'lassadhaboubi@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$3HUADOG/aUksj7Vc9rCc1g$h1XlxsSq0s9J1qs4S+xX3enrgLPj9qV4WGiUDfFpsAQ', 'Lassad', 'Haboubi', '', '', '', '4', '', 'yassmine', '', '', '5940BI', '', '', '', '0x9A10667ab5492DfbFF574B4DC008343bd7D8e066', '0x166fb96a89160936e0e72f0e17231e597e7ff1aa1a09bdf470fc133f003110b9', 21744743, 1),
(63, 'hamediguesmi@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$BT0RyuiUEdQkEbMOUzS8Sw$YIAksBHeu8v1BZfeJqVNzRcWXse5tyrH7sEI5YjTaGs', 'Hamedi', 'Guesmi', '', '', '', '4', '', 'Oumaima', '', '', '5549BI', '', '', '', '0x26328DBC3e3E90556cb8A655D421D0fe11b379BF', '0xa0929c263ce2b2d7ec1623330835d1c383cb76273113608c5f2f241f6b289737', 12345678, 1),
(64, 'bechirnemri@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$+XBca7sIZ8v2N4FKD0j8hw$jx9C/DwDGQkVAX2jXFOeGTjFrnb1lyt+IeM+qa/Wzrg', 'Mohamed bechir', 'Nemri', '', '', '', '4', '', 'Tej', '', '', '6157BI', '', '', '', '0xbceBac90B9406e05a5F0774231805F0aD6921439', '0x6656e32c24fd4b1c674bf377e5b3b92c3690a5232d63afa0ae3e17b35f410a50', 20656481, 1),
(65, 'jalelbensalha@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$Cy07s1W/o/b93twFfAJfjA$kIIqQAL2Zfq81Z2b2S7WRc5tsPgIbOZLc1mUwzVkq9Q', 'Jalel', 'Ben salha', '', '', '', '4', '', 'MARIEM', '', '', '11781BI', '', '', '', '0x7A338a1621A974C29F17a888F26aC83fb7C58191', '0xafcaa04cc23ec0baa7958bde64650acaff339b6d9ca2e9b2e4a192f0c39ee4e9', 20656481, 1),
(66, 'bechirnijaoui@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$FHm7LptJIpkkEROiifJuOg$lSNhElsgYSpNbhiHqkKowJGlQA8R+YfmlGBo3zZpz4w', 'Bechir', 'Nijaoui', '', '', '', '4', '', 'Aziza', '', '', '6175BI', '', '', '', '0xf6f17C94c55ff74FA2d21C121dc384a40769d0dE', '0x52ceee89f1aa55adf5efb82a595aad15600c34d846c18e9d25ca23e944e5f768', 20656481, 1),
(67, 'soussihassen@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$0itpQbfJMdL0hPAZhTgPhg$tFxf7U9kMLV2+Iw/OmCIpufYqcrFLBb5o8cJQ5rjpPI', 'Soussi', 'Hassen', '', '', '', '5.2', '', 'ALAA', '', '', '3611BI', '', '', '', '0x7b8DF655a561DF75B8BEb957Aaf0577cA7450696', '0x4db09e90197746e0beda4f300b5dbf583c7d891847e0acd779fa76afed7dd3c4', 12345678, 1),
(68, 'alimansour@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$AOQ+FsyROJSwrcaXzctYiA$sRLuFdek1Yw6EJ8s08aJ9zZMHiG5tbAQwWd1QKpwmGE', 'Ben Gara', 'Ali Mansour', '', '', '', '5.5', '', 'AYA', 'Tunis', '', '3156BI', '', 'Zarzouna', 'Ben Gara', '0xc795F37bf40F1C5EC2024C345519e53e37f6e3C9', '0xaeca2178ddabfdd10f0e2752541da55be68f3171b7ff567242a530a50904b9ae', 94513189, 1),
(69, 'mohamedomar@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$A3a8bwSepVTyDYff2EZwEg$MfN7BpUUSOtszWzHh2BwT1L+OvJlSp+A/baqsw0fxrY', 'Ben Omar Soussi', 'Mohamed', '', '', '', '5', '', 'Yakouta', '', '', '5791BI', '', '', '', '0x74ccd52fD67B1082a3130b8A58aCa466C296F1B5', '0x993f08147c91338cb654c5b6d0f597c559e0851a60bdf9055981d815e819ad10', 12345678, 1),
(70, 'dridi@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$KZmYtem7qVULnFOR/Z55rw$LEtx2qpkhcZGe4rPyv/+dzA0GmTl3cIBG7oa5Lto6TQ', 'Dridi', 'Abderraouf', '', '', '', '5', '', 'Asma', '', '', '3430BI', '', '', '', '0x580da91630a54f45D77C803580Da32e7d649bdB3', '0x68b3aff05613ea7f26838e8985d6a352fcb3ebc066782e5a1b038ec9d0a17e90', 12345678, 1),
(71, 'issamab@gmail.com', '[\"ROLE_PECHEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$0Z9da1LSCHl6o784W7NQuw$heGMD3S7Ehtxomlwf2wfwJMiv4C/trExG0MQwAMZdbs', 'Issam', 'Abaissia', '', '', '', '5', '', 'Tej', '', '', '6861BI', '', '', '', '0x65db35f50bf8F7467354130dC1341A27E77f7200', '0x232e50654bc471e5b7fc2c04b699c574380ab83c0c60a957ef754bd00ec7e41c', 97272875, 1);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_picture`
--

CREATE TABLE `marketplace_picture` (
  `id` int NOT NULL,
  `publication_id` int DEFAULT NULL,
  `image_url` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_picture`
--

INSERT INTO `marketplace_picture` (`id`, `publication_id`, `image_url`) VALUES
(3, 2, '6f5cee0eb2c7d3e603c4c0650f436132.png'),
(4, 3, 'bateau3.png'),
(5, 4, 'bateau1.jpg'),
(6, 5, '8c9ef630cd36bb5777a2ee3c2e76ad9a.jpeg'),
(7, 5, 'f36152b75e097c697eb71d845d1c4b2a.jpeg'),
(8, 5, '930ac8bfa1f7cc098daf7c3319a0f943.jpeg');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_prise`
--

CREATE TABLE `marketplace_prise` (
  `id` int NOT NULL,
  `pecheur_id` int DEFAULT NULL,
  `maryeur_id` int DEFAULT NULL,
  `nom` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `debut` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `fin` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `latitude` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `langitude` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `engin` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `zone` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `affectationdate` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `datedebarquement` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_prise`
--

INSERT INTO `marketplace_prise` (`id`, `pecheur_id`, `maryeur_id`, `nom`, `debut`, `fin`, `latitude`, `langitude`, `engin`, `zone`, `affectationdate`, `datedebarquement`) VALUES
(56, 2, 2, 'test', '2023-11-10 01:12', '2023-11-10 01:12', '37.232303333333', '9.861785', 'Fillet', 'FAO 37', '2023-11-10 01:15', '2023-11-10 01:14'),
(57, 35, 2, 'test', '2023-11-10 14:15', '2023-11-10 14:16', '0', '0', '', 'FAO 37', '2023-11-10 14:20', '2023-11-10 14:20'),
(58, 37, 2, 'test', '2023-11-10 14:33', '2023-11-10 14:34', '37.279678333333', '9.88076', '', 'FAO 37', '2023-11-10 14:36', '2023-11-10 14:36'),
(59, 41, 2, 'test', '2023-11-10 15:00', '2023-11-10 15:00', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(60, 40, 2, 'test', '2023-11-10 15:32', '2023-11-10 15:32', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(61, 40, 2, 'test', '2023-11-10 15:37', '2023-11-10 15:38', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(62, 39, 3, 'test', '2023-11-10 16:08', '2023-11-10 16:08', '0', '0', '', 'FAO 37', '2023-11-10 16:10', '2023-11-10 16:10'),
(63, 38, 2, 'test', '2023-11-10 16:36', '2023-11-10 16:36', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(64, 35, 2, 'test', '2023-11-10 17:07', NULL, '37.279678333333', '9.88076', 'Tabekh', 'FAO 37', NULL, NULL),
(65, 35, 2, 'test', '2023-11-10 17:08', '2023-11-10 17:09', '0', '0', 'Tabekh', 'FAO 37', NULL, NULL),
(66, 58, 2, 'test', '2023-11-11 09:36', '2023-11-11 09:37', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(67, 34, 2, 'test', '2023-11-11 10:00', '2023-11-11 10:00', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(68, 34, 2, 'test', '2023-11-11 10:02', '2023-11-11 10:03', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(69, 59, 2, 'test', '2023-11-11 10:11', '2023-11-11 10:11', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(70, 60, 2, 'test', '2023-11-11 10:35', '2023-11-11 10:35', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(71, 62, 2, 'test', '2023-11-11 11:07', '2023-11-11 11:07', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(72, 63, 2, 'test', '2023-11-11 11:19', '2023-11-11 11:19', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(73, 33, 2, 'test', '2023-11-11 11:44', '2023-11-11 11:45', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(74, 33, 2, 'test', '2023-11-11 11:46', '2023-11-11 11:46', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(75, 64, 2, 'test', '2023-11-11 12:18', '2023-11-11 12:18', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(76, 32, 2, 'test', '2023-11-11 12:54', '2023-11-11 12:54', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(77, 36, 2, 'test', '2023-11-11 13:08', '2023-11-11 13:08', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(78, 65, 2, 'test', '2023-11-11 13:38', '2023-11-11 13:39', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(79, 54, 2, 'test', '2023-11-11 14:09', '2023-11-11 14:10', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(80, 53, 2, 'test', '2023-11-11 14:29', '2023-11-11 14:29', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(81, 43, 2, 'test', '2023-11-11 14:34', '2023-11-11 14:34', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(82, 47, 2, 'test', '2023-11-11 15:05', '2023-11-11 15:05', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(83, 47, 2, 'test', '2023-11-11 15:07', '2023-11-11 15:07', '37.279678333333', '9.88076', '', 'FAO 37', NULL, NULL),
(84, 2, 2, 'test', '2023-11-12 15:50', '2023-11-12 15:51', '36.85376', '10.282885', 'Fillet', 'FAO 37', '2023-11-12 15:53', '2023-11-12 15:54'),
(87, 56, 2, 'test', '2023-11-15 13:53', '2023-11-15 13:53', '0', '0', '', 'FAO 37', NULL, '2023-11-15 13:55'),
(88, 56, 2, 'test', '2023-11-15 14:02', '2023-11-15 14:02', '0', '0', '', 'FAO 37', NULL, NULL),
(89, 56, 2, 'test', '2023-11-15 14:03', '2023-11-15 14:04', '0', '0', '', 'FAO 37', NULL, NULL),
(90, 52, 2, 'test', '2023-11-16 13:18', '2023-11-16 13:18', '36.811446666667', '10.1183', 'Hacheni', 'FAO 37', NULL, NULL),
(91, 68, 2, 'test', '2023-11-17 10:53', '2023-11-17 10:53', '36.811446666667', '10.1183', '', 'FAO 37', NULL, NULL),
(92, 52, 2, 'test', '2023-11-17 11:05', '2023-11-17 11:05', '36.811446666667', '10.1183', 'Hacheni', 'FAO 37', NULL, NULL),
(93, 51, 2, 'test', '2023-11-17 11:13', '2023-11-17 11:13', '36.811446666667', '10.1183', '', 'FAO 37', NULL, NULL),
(94, 48, 2, 'test', '2023-11-17 11:22', '2023-11-17 11:22', '36.811446666667', '10.1183', '', 'FAO 37', NULL, NULL),
(95, 56, 2, 'test', '2023-11-17 12:16', '2023-11-17 12:16', '36.811446666667', '10.1183', '', 'FAO 37', NULL, '2023-11-17 15:04'),
(96, 2, 2, 'test', '2023-11-23 15:48', '2023-11-23 15:49', '0', '0', 'Fillet', 'FAO 37', NULL, NULL),
(97, 38, 2, 'test', '2023-11-24 12:32', '2023-11-24 12:32', '0', '0', '', 'FAO 37', NULL, NULL),
(98, 70, 2, 'test', '2023-11-24 15:24', '2023-11-24 15:24', '0', '0', '', 'FAO 37', NULL, '2023-11-30 20:23'),
(99, 46, 2, 'test', '2023-11-24 15:30', '2023-11-24 15:31', '37.231927286775', '9.8614847615223', '', 'FAO 37', NULL, NULL),
(100, 41, 2, 'test', '2023-11-24 17:02', '2023-11-24 17:02', '0', '0', '', 'FAO 37', NULL, NULL),
(101, 36, 2, 'test', '2023-11-30 10:37', '2023-11-30 10:37', '37.27815999', '9.87649342', '', 'FAO 37', NULL, '2023-11-30 10:39'),
(102, 36, 2, 'test', '2023-11-30 10:42', '2023-11-30 10:42', '37.27820651', '9.87650502', '', 'FAO 37', NULL, NULL),
(103, 39, 2, 'test', '2023-11-30 11:27', '2023-11-30 11:28', '37.27820651', '9.87650502', '', 'FAO 37', NULL, NULL),
(104, 33, 2, 'test', '2023-11-30 12:08', '2023-11-30 12:08', '37.24605401', '9.85295417', '', 'FAO 37', NULL, NULL),
(105, 38, 2, 'test', '2023-11-30 12:21', '2023-11-30 12:21', '37.24605401', '9.85295417', '', 'FAO 37', NULL, NULL),
(106, 62, 2, 'test', '2023-11-30 12:52', '2023-11-30 12:52', '37.24605401', '9.85295417', '', 'FAO 37', NULL, NULL),
(107, 41, 2, 'test', '2023-11-30 13:15', '2023-11-30 13:16', '37.24605401', '9.85295417', '', 'FAO 37', NULL, NULL),
(108, 60, 2, 'test', '2023-11-30 13:29', '2023-11-30 13:29', '37.24605401', '9.85295417', '', 'FAO 37', NULL, NULL),
(109, 70, 2, 'test', '2023-11-30 20:19', '2023-11-30 20:20', '0', '0', '', 'FAO 37', NULL, '2023-11-30 20:23'),
(110, 58, 2, 'test', '2023-12-06 10:12', '2023-12-06 10:13', '36.810433333333', '10.172436666667', '', 'FAO 37', NULL, NULL),
(111, 58, 2, 'test', '2023-12-06 10:14', NULL, '36.810433333333', '10.172436666667', '', 'FAO 37', NULL, NULL),
(112, 58, 2, 'test', '2023-12-06 10:15', '2023-12-06 10:15', '36.810433333333', '10.172436666667', '', 'FAO 37', NULL, NULL),
(113, 58, 2, 'test', '2023-12-06 10:17', '2023-12-06 10:17', '36.810433333333', '10.172436666667', '', 'FAO 37', NULL, NULL),
(114, 32, 2, 'test', '2023-12-06 10:52', '2023-12-06 10:52', '37.265325', '9.8857216666667', '', 'FAO 37', NULL, NULL),
(115, 59, 2, 'test', '2023-12-06 11:30', '2023-12-06 11:30', '37.265325', '9.8857216666667', '', 'FAO 37', NULL, NULL),
(116, 40, 2, 'test', '2023-12-06 12:42', '2023-12-06 12:42', '37.265325', '9.8857216666667', '', 'FAO 37', NULL, NULL),
(117, 70, 2, 'test', '2023-12-06 14:02', '2023-12-06 14:02', '37.271306666667', '9.8695916666667', '', 'FAO 37', NULL, NULL),
(118, 47, 2, 'test', '2023-12-06 14:07', '2023-12-06 14:07', '37.271306666667', '9.8695916666667', '', 'FAO 37', NULL, NULL),
(119, 46, 2, 'test', '2023-12-06 14:11', '2023-12-06 14:11', '37.271306666667', '9.8695916666667', '', 'FAO 37', NULL, NULL),
(120, 51, 2, 'test', '2023-12-06 14:15', '2023-12-06 14:15', '37.271306666667', '9.8695916666667', '', 'FAO 37', NULL, '2024-02-28 04:27'),
(121, 35, 2, 'test', '2023-12-06 14:26', '2023-12-06 14:26', '37.271306666667', '9.8695916666667', 'مجموعة شباك خيشومية للعينات والسردين والبوري والصوبات الزراعية', 'FAO 37', NULL, NULL),
(122, 52, 2, 'test', '2023-12-06 14:49', '2023-12-06 14:49', '37.271306666667', '9.8695916666667', 'Hacheni', 'FAO 37', NULL, NULL),
(123, 64, 2, 'test', '2023-12-06 15:12', '2023-12-06 15:12', '37.271306666667', '9.8695916666667', '', 'FAO 37', NULL, NULL),
(124, 43, 2, 'test', '2023-12-06 15:45', '2023-12-06 15:45', '37.225806666667', '9.9148483333333', '', 'FAO 37', NULL, NULL),
(125, 54, 2, 'test', '2023-12-06 15:57', '2023-12-06 15:57', '37.225806666667', '9.9148483333333', 'Boukoum', 'FAO 37', NULL, NULL),
(126, 53, 2, 'test', '2023-12-06 16:06', '2023-12-06 16:06', '37.225806666667', '9.9148483333333', '', 'FAO 37', NULL, NULL),
(127, 37, 2, 'test', '2023-12-06 16:21', '2023-12-06 16:21', '37.225806666667', '9.9148483333333', '', 'FAO 37', NULL, NULL),
(128, 34, 2, 'test', '2023-12-06 16:37', '2023-12-06 16:37', '37.225806666667', '9.9148483333333', '', 'FAO 37', NULL, NULL),
(129, 71, 2, 'test', '2023-12-07 15:51', '2023-12-07 15:51', '36.829896666667', '10.178781666667', '', 'FAO 37', NULL, '2024-02-28 04:27'),
(130, 71, 2, 'test', '2023-12-07 15:52', '2023-12-07 15:52', '36.829896666667', '10.178781666667', '', 'FAO 37', NULL, '2024-02-28 04:27'),
(131, 65, 2, 'test', '2023-12-07 15:56', '2023-12-07 15:57', '36.829896666667', '10.178781666667', '', 'FAO 37', NULL, '2024-02-28 04:27'),
(132, 2, 2, 'test', '2023-12-08 14:37', NULL, '0', '0', 'Fillet', 'FAO 37', NULL, '2024-02-28 04:27'),
(133, 2, 2, 'test', '2023-12-10 21:08', NULL, '36.855675', '10.281905', 'Fillet', 'FAO 37', NULL, '2024-02-28 04:27'),
(134, 2, 2, 'test', '2023-12-15 16:46', '2023-12-15 16:46', '36.803715038113', '10.145549308509', 'Fillet', 'FAO 37', NULL, '2024-02-28 04:27'),
(135, 2, 2, 'test', '2024-02-27 17:06', NULL, '0', '0', 'Fillet', 'FAO 37', NULL, '2024-02-28 04:19'),
(136, 2, 2, 'test', '2024-02-28 12:21', '2024-02-28 12:22', '0', '0', 'Fillet', 'FAO 37', NULL, '2024-02-28 04:25'),
(137, 2, 2, 'test', '2024-02-28 12:26', '2024-02-28 12:26', '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-10 16:35'),
(138, 2, 2, 'test', '2024-12-18 18:25', '2024-12-18 18:25', '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-10 16:30'),
(139, 2, 2, 'test', '2024-12-18 18:37', '2024-12-18 18:37', '0', '0', 'Fillet', 'FAO 37', '2024-12-18 18:38', '2024-12-18 18:38'),
(140, 2, 2, 'test', '2024-12-19 13:20', NULL, '36.85657', '10.28047', 'Fillet', 'FAO 37', '2024-12-19 13:24', '2024-12-19 13:24'),
(141, 2, 2, 'test', '2025-02-04 13:49', NULL, '0', '0', 'Fillet', 'FAO 37', '2025-02-04 13:50', '2025-02-04 13:50'),
(142, 2, 2, 'test', '2025-02-04 13:51', '2025-02-04 13:52', '0', '0', 'Fillet', 'FAO 37', '2025-02-04 13:52', '2025-02-5 16:44'),
(143, 2, 2, 'test', '2025-02-05 11:00', '2025-02-05 11:02', '0', '0', 'Fillet', 'FAO 37', '2025-02-05 11:05', '2025-02-05 11:03'),
(144, 2, 2, 'test', '2025-02-05 11:38', '2025-02-05 11:38', '0', '0', 'Fillet', 'FAO 37', '2025-02-05 12:22', '2025-02-05 12:22'),
(145, 2, 2, 'test', '2025-02-05 12:23', '2025-02-05 12:23', '36.850408333333', '10.116751666667', 'Fillet', 'FAO 37', '2025-02-05 12:37', '2025-02-05 12:25'),
(146, 2, 2, 'test', '2025-02-05 12:27', '2025-02-05 12:27', '36.850408333333', '10.116751666667', 'Fillet', 'FAO 37', '2025-02-05 12:37', '2025-02-05 12:37'),
(147, 2, 2, 'test', '2025-02-05 12:39', '2025-02-05 12:39', '36.850408333333', '10.116751666667', 'Fillet', 'FAO 37', '2025-02-05 12:42', '2025-02-05 12:42'),
(148, 2, NULL, 'test', '2025-02-10 16:24', '2025-02-10 16:24', '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-10 16:40'),
(149, 2, 2, 'test', '2025-02-10 16:32', '2025-02-10 16:32', '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-10 16:44'),
(150, 2, 2, 'test', '2025-02-10 16:44', '2025-02-10 16:44', '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-10 16:44'),
(151, 2, 2, 'test', '2025-02-11 11:15', '2025-02-11 11:16', '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-11 11:16'),
(152, 2, 2, 'test', '2025-02-11 11:26', '2025-02-11 11:27', '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-11 11:18'),
(153, 2, 2, 'test', '2025-02-11 11:36', NULL, '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-11 11:20'),
(154, 2, 2, 'test', '2025-02-11 11:39', NULL, '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-11 11:29'),
(155, 2, 2, 'test', '2025-02-11 11:44', '2025-02-11 11:44', '36.821883333333', '10.186696666667', 'Fillet', 'FAO 37', NULL, '2025-02-11 11:30'),
(156, 2, 2, 'test', '2025-02-11 11:49', '2025-02-11 11:49', '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-11 11:35'),
(157, 2, 2, 'test', '2025-02-19 13:57', '2025-02-19 13:57', '36.791303333333', '10.119426666667', 'Fillet', 'FAO 37', NULL, '2025-02-19 14:03'),
(158, 2, 2, 'test', '2025-02-19 14:13', '2025-02-19 14:13', '36.791303333333', '10.119426666667', 'Fillet', 'FAO 37', NULL, '2025-02-19 14:14'),
(159, 2, 2, 'test', '2025-02-19 14:17', '2025-02-19 14:17', '36.791303333333', '10.119426666667', 'Fillet', 'FAO 37', NULL, '2025-02-19 14:18'),
(160, 2, 2, 'test', '2025-02-19 16:18', '2025-02-19 16:18', '36.791303333333', '10.119426666667', 'Fillet', 'FAO 37', NULL, '2025-02-19 16:19'),
(161, 2, 2, 'test', '2025-02-19 16:23', '2025-02-19 16:24', '36.791303333333', '10.119426666667', 'Fillet', 'FAO 37', NULL, '2025-02-19 16:24'),
(162, 2, 2, 'test', '2025-02-20 11:34', '2025-02-20 11:35', '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-20 11:35'),
(163, 2, 2, 'test', '2025-02-20 11:39', '2025-02-20 11:41', '0', '0', 'Fillet', 'FAO 37', NULL, '2025-02-20 11:42');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_produit`
--

CREATE TABLE `marketplace_produit` (
  `id` int NOT NULL,
  `categorie_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `nom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `description` varchar(3000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `stock` int NOT NULL,
  `prix` double NOT NULL,
  `min` int NOT NULL,
  `max` int NOT NULL,
  `discount` double DEFAULT NULL,
  `vu` int NOT NULL,
  `visibilite` tinyint(1) NOT NULL,
  `typologie` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `datedeconsomation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `datedepeche` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `methodedecapture` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `zonedepeche` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `transformation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `conservation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `congelation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `glazing` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `taille` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `certification` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `emballage` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `poidemballage` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `imported` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `certifie` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_produit`
--

INSERT INTO `marketplace_produit` (`id`, `categorie_id`, `user_id`, `nom`, `description`, `stock`, `prix`, `min`, `max`, `discount`, `vu`, `visibilite`, `typologie`, `datedeconsomation`, `datedepeche`, `methodedecapture`, `zonedepeche`, `transformation`, `conservation`, `congelation`, `glazing`, `taille`, `certification`, `emballage`, `poidemballage`, `imported`, `certifie`) VALUES
(9, 4, 37, 'Frigate tuna', 'Frigate tuna, HGT, block frozen, 1/10kg', 100, 100, 100, 100, NULL, 127, 1, 'pêche artisanale', '01/01/2024', '15/12/2022', 'Filet maillant', 'tunisie sud', 'congélé', 'La mise sous glace', 'Bloc surgelé', '15%', '16 cm', 'IFS', 'filets', '12 g', NULL, NULL),
(10, 5, 37, 'MSC Saumon', 'MSC Frozen Saumon ', 16, 1000, 30, 16, NULL, 299, 1, 'Pêche industrielle', '01/01/2024', '16/12/2022', 'Filet maillant', 'sisilia', 'congélé', 'La mise sous glace', 'IQF(Individually Quick Frozen)', '16 C', '15cm', 'HACCP', 'boîte en carton avec doublure en polyéthylène', '100G', NULL, NULL),
(11, 5, 37, 'MSC Frozen Merlu', 'MSC Frozen Pink Merlu HG', 0, 50, 100, 0, 10, 221, 1, 'Pêche industrielle', '2024', '2017', 'Filet maillant', 'italie', 'congélé', 'La mise sous glace', 'Bloc surgelé', '4 C', '16 cm', 'BRC', 'boîte en carton avec doublure en polyéthylène', '16 cm', NULL, NULL),
(12, 4, 37, 'Bullet tuna WR', 'Bullet tuna WR 100-300, 1/10kg', 0, 100, 50, 0, NULL, 98, 1, 'aquaculture /élevage', '2022', '2015', 'filets similaires (Trémails)', 'tunisie', 'fumé', 'Placez les produits au plus vite au frais', 'Bloc surgelé', '67 C', '16 cm', 'ISO', 'filets', '23 g', NULL, NULL),
(13, 6, 37, 'Rouget', 'Blue Merlu, frozen', -54, 100, 80, -54, NULL, 40, 1, 'Pêche industrielle', '2023', '2022', 'Chalutage (chalut de fond, Chalut pélagique)', 'tunisie', 'congélé', 'Placez les produits au plus vite au frais', 'IQF(Individually Quick Frozen)', '16 c', '16 cm', 'IFS', 'sac', '24 g', NULL, NULL),
(14, 5, 37, 'Merlu ', ' 2/4 , 4/6 , 6/8, 2kg., 2kg box', 0, 50, 100, 0, NULL, 241, 1, 'aquaculture /élevage', '2023', '2022', 'filets similaires (Trémails)', 'tunisie', 'salé', 'La mise sous glace', 'IQF(Individually Quick Frozen)', '45 c', '24 g', 'HACCP', 'sac', '34 g', NULL, NULL),
(15, 9, 37, 'crab', 'Les Brachyura est un infra-ordre de l\'ordre des crustacés décapodes dotés d\'une carapace plutôt plate et d\'un abdomen court et large placé sous le thorax. On distingue les Brachyura, les vrais crabes, des Anomura, qui comprennent plusieurs autres crustacés également appelés crabes.', 12, 20, 5, 12, 2, 0, 0, 'Pêche industrielle', '', '', 'Récolte des mollusques et crustacés (Draguer, Pièges et pots)', '', 'congélé', 'Placez les produits au plus vite au frais', 'Bloc surgelé', '', '10', 'IFS', '', '', NULL, NULL),
(16, 3, 37, 'a', 'aa', 10, 1, 1, 7, NULL, 5, 0, 'autres', '', '', '', '', '', '', '', '', '', '', '', '', NULL, NULL),
(18, 4, 37, 'tik', 'gg', 14, 1233, 4, 9, 14, 2, 1, 'pêche artisanale', '27/09/2024', '16/09/2024', 'scène', '14', 'fumé', 'Placez les produits au plus vite au frais', 'BQF(Block Quick Frozen)', 'YES', '14', 'IFS', 'sac', '14', NULL, NULL),
(24, 3, 37, 'السريولا', 'DHDH', 6, 310, 2, 5, 14, 20, 1, 'pêche artisanale', '25/09/2024', '09/09/2024', 'scène', 'FAO 37', 'en état (poisson entier)', 'Conserver entre -8 et +25C', 'BQF(Block Quick Frozen)', 'YES', '14', 'GMP', 'vrac', '14', NULL, 1),
(25, 3, 118, 'السريولا1', 'DHDH', 4, 310, 2, 2, 14, 46, 1, 'pêche artisanale', '25/09/2024', '09/09/2024', 'scène', 'FAO 37', 'en état (poisson entier)', 'Conserver entre -8 et +25C', 'BQF(Block Quick Frozen)', 'YES', '14', 'GMP', 'vrac', '14', NULL, 1),
(26, 3, 118, 'السريولا3', 'DHDH', 4, 310, 2, 2, 14, 93, 1, 'pêche artisanale', '25/09/2024', '09/09/2024', 'scène', 'FAO 37', 'en état (poisson entier)', 'Conserver entre -8 et +25C', 'BQF(Block Quick Frozen)', 'YES', '14', 'GMP', 'vrac', '14', NULL, 1),
(27, 3, 118, 'السريولا34', 'test', 2, 310, 2, 2, 14, 103, 1, 'pêche artisanale', '25/09/2024', '09/09/2024', 'scène', 'FAO 37', 'en état (poisson entier)', 'Conserver entre -8 et +25C', 'BQF(Block Quick Frozen)', 'YES', '14', 'GMP', 'vrac', '14', NULL, 1),
(28, 6, 37, 'test', 'test', 100, 500, 1, 20, NULL, 0, 0, 'pêche artisanale', '30/11/2024', '23/11/2024', 'scène', 'test', 'en état (poisson entier)', 'La mise sous glace', 'BQF(Block Quick Frozen)', '', '14', 'ISO', 'Emballage sous vide', '30', NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_produitvendus`
--

CREATE TABLE `marketplace_produitvendus` (
  `id` int NOT NULL,
  `commande_id` int DEFAULT NULL,
  `produit_id` int DEFAULT NULL,
  `nom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `quantite` int NOT NULL,
  `prix` double NOT NULL,
  `totale` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_produitvendus`
--

INSERT INTO `marketplace_produitvendus` (`id`, `commande_id`, `produit_id`, `nom`, `quantite`, `prix`, `totale`) VALUES
(57, 96, 26, 'السريولا3', 2, 266.6, 533.2),
(58, 96, 25, 'السريولا1', 2, 266.6, 533.2),
(59, 97, 10, 'MSC Saumon', 30, 1000, 30000),
(64, 101, 25, 'السريولا1', 2, 266.6, 533.2),
(65, 101, 26, 'السريولا3', 2, 266.6, 533.2),
(66, 102, 27, 'السريولا34', 2, 266.6, 533.2),
(67, 103, 27, 'السريولا34', 2, 266.6, 533.2);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_publication`
--

CREATE TABLE `marketplace_publication` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `titre` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `critere` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `categorie` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `date` datetime NOT NULL,
  `prix` double NOT NULL,
  `etat` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `adresse` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `pays` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `region` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `ville` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `visibilite` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_publication`
--

INSERT INTO `marketplace_publication` (`id`, `user_id`, `titre`, `description`, `critere`, `categorie`, `date`, `prix`, `etat`, `adresse`, `pays`, `region`, `ville`, `visibilite`) VALUES
(2, 37, 'bateau a vendre', 'OPTIONS : Panneaux solaires, joystick, plateforme de bain et cockpit teck, propulseur d’étrave, taud de camping, réfrigérateur intérieur / extérieur…\nMotorisation 2 x Volvo Penta D3-220 avec JOYSTICK.\nLEASING TVA 10% INTERESSANT A REPRENDRE.', 'Année \n2018\nFabricant \nJeanneau\nModèle \nLeader 33\nType \nVedettes Sportives\nLongueur \n8,82m\nType de Moteur / Essence \nDiesel\nMatériau de la Coque \nFibres De Verre / Polyester\nForme de la Coque \nCoque En V Modifiée\nProposé par \nPlaisir D\'O Yacht Agency', 'Bateau', '2023-01-18 13:44:42', 2000000, 'Noeuf', 'Port de Pêche de Menzel Abderrahmane', 'Tunisie', 'Nord Tunisie', 'Bizerte', 1),
(3, 37, 'Bateau ocassion', 'OPTIONS : Panneaux solaires, joystick, plateforme de bain et cockpit teck, propulseur d’étrave, taud de camping, réfrigérateur intérieur / extérieur…\nMotorisation 2 x Volvo Penta D3-220 avec JOYSTICK.\nLEASING TVA 10% INTERESSANT A REPRENDRE.\n\n\n', 'Année \n2023\nFabricant \nRapsody\nModèle \nTender\nType \nCoques Open\nLongueur \n9,05m\nType de Moteur / Essence \nDiesel\nMatériau de la Coque \nFibres De Verre / Polyester\nForme de la Coque \nDeep Vee\nGarantie \n2 Ans\nProposé par \nRapsody Yachts', 'Bateau', '2023-01-18 13:46:18', 500, 'Occasion', 'Port de Pêche de Menzel Abderrahmane', 'Tunisie', 'Nord Tunisie', 'Bizerte', 1),
(4, 37, 'Bateau model (x4567)', '2012 King Marine Dixon 73\nKAHUNA has been built by the well know shipyard King Marine (Compañia de Barcos) in Argentina and has been finished by M-Boats, Argentina.', 'Année \n2012\nFabricant \nKing Marine\nModèle \nDixon 73\nType \nSloops\nLongueur \n22,30m\nType de Moteur / Essence \nDiesel\nMatériau de la Coque \nComposite\nForme de la Coque \nMonocoque\nProposé par \nNorthrop And Johnson (Palma)', 'Divers', '2023-01-18 13:47:26', 600, 'Noeuf', 'Port de Pêche de Menzel Abderrahmane', 'Tunisie', 'Nord Tunisie', 'Bizerte', 1),
(5, 37, 'yakht264', '312E8C', 'Année \n2012\nFabricant \nKing Marine\nModèle \nDixon 73\nType \nSloops\nLongueur \n22,30m\nType de Moteur / Essence \nDiesel\nMatériau de la Coque \nComposite\nForme de la Coque \nMonocoque\nProposé par \nNorthrop And Johnson (Palma)', 'Bateau', '2023-09-22 16:29:59', 59599, 'Noeuf', 'Port de Pêche de Menzel Abderrahmane', 'Tunisie', 'Nord Tunisie', 'Bizerte', 1);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_reservation`
--

CREATE TABLE `marketplace_reservation` (
  `id` int NOT NULL,
  `salon_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `statut_reservation` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_rfid`
--

CREATE TABLE `marketplace_rfid` (
  `id` int NOT NULL,
  `pecheur_id` int DEFAULT NULL,
  `rfid` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `lot_id` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_rfid`
--

INSERT INTO `marketplace_rfid` (`id`, `pecheur_id`, `rfid`, `lot_id`) VALUES
(1, 27, 'A2 56 4D 96', '111'),
(2, 28, '7a2eebae', NULL),
(3, 27, 'c3a680c', NULL),
(4, 29, 'aaf45db4', NULL),
(5, 2, '5a2a4fb4', NULL),
(6, 27, 'daf055b4', NULL),
(7, NULL, '12345', NULL),
(8, NULL, '12235', NULL),
(9, NULL, '5555', NULL),
(10, NULL, '12333', NULL),
(11, NULL, 'test', NULL),
(12, NULL, '45tt', NULL),
(13, NULL, '123345', NULL),
(14, NULL, '7aeebae', NULL),
(15, NULL, '1234577', NULL),
(16, NULL, '7a2eebae', NULL),
(17, NULL, '7a2eebae', NULL),
(18, NULL, '7a2eebae', NULL),
(19, NULL, '3523', NULL),
(20, NULL, '7a2eebae', NULL),
(21, NULL, '1234577', NULL),
(22, NULL, '7a2eebae', NULL),
(23, NULL, 'c3a680c', NULL),
(24, NULL, '7a2eebae', NULL),
(25, NULL, 'aaf45db4', NULL),
(26, NULL, 'aaf45db4', NULL),
(27, NULL, '123477', NULL),
(28, NULL, '12345778', NULL),
(29, NULL, '12345778', NULL),
(30, NULL, '12345778', NULL),
(31, NULL, '1234588', NULL),
(32, NULL, '1234577', NULL),
(33, NULL, '34567', NULL),
(34, NULL, '125567', NULL),
(35, NULL, '123456', NULL),
(36, NULL, '4444', NULL),
(37, NULL, '2222', NULL),
(38, NULL, '2222', NULL),
(39, NULL, '333355', NULL),
(40, NULL, '333355', NULL),
(41, NULL, '333355', NULL),
(42, NULL, '123477', NULL),
(43, NULL, '33441', NULL),
(44, NULL, '33441', NULL),
(45, NULL, '123456', NULL),
(46, NULL, '12345', NULL),
(47, NULL, '12345', NULL),
(48, NULL, 'rrr', NULL),
(49, NULL, 'trdss', NULL),
(50, NULL, 'trzz', NULL),
(51, NULL, 'ffff', NULL),
(52, NULL, 'yyyy', NULL),
(53, NULL, 'ttttt', NULL),
(54, NULL, 'ccccc', NULL),
(55, NULL, 'rrttc', NULL),
(56, NULL, 'ttessf', NULL),
(57, NULL, 'trrr', NULL),
(58, NULL, 'yyyy', NULL),
(59, NULL, 'ttrre', NULL),
(60, NULL, 'tteeec', NULL),
(61, NULL, 'azrty', NULL),
(62, NULL, 'azert', NULL),
(63, NULL, 'yyuybh', NULL),
(64, NULL, 'yyuybh', NULL),
(65, NULL, 'uuhh', NULL),
(66, NULL, '125567', NULL),
(67, NULL, '55rr', NULL),
(68, NULL, '55rr', NULL),
(69, NULL, '55rr', NULL),
(70, NULL, '55rr', NULL),
(71, NULL, '5zfxx', NULL),
(72, NULL, '5zfxx', NULL),
(73, NULL, 'aaaaaa', NULL),
(74, NULL, '3454e', NULL),
(75, NULL, '1111', NULL),
(76, NULL, '3455g', NULL),
(77, NULL, 'ytrfg', NULL),
(78, NULL, '556yt', NULL),
(79, NULL, 'yyyrty', NULL),
(80, NULL, 'rrrrty', NULL),
(81, NULL, 'rtyu', NULL),
(82, NULL, 'dfrr', NULL),
(83, NULL, 'hhhh', NULL),
(84, NULL, 'yytert', NULL),
(85, NULL, 'tyuuu', NULL),
(86, NULL, 'tttdf', NULL),
(87, NULL, 'hhgf', NULL),
(88, NULL, '', NULL),
(89, NULL, '1', NULL),
(90, NULL, 'rrft', NULL),
(91, NULL, 'rtaa', NULL),
(92, NULL, 'zertyy', NULL),
(93, NULL, 'rticc', NULL),
(94, NULL, 'rty', NULL),
(95, NULL, 'cckcc', NULL),
(96, NULL, 'cckcc', NULL),
(97, NULL, 'ergcv', NULL),
(98, NULL, 'fghhr', NULL),
(99, NULL, 'rtttc', NULL),
(100, NULL, 'fghvl', NULL),
(101, NULL, 'gccc', NULL),
(102, NULL, 'fxxf', NULL),
(103, NULL, 'fgvc', NULL),
(104, NULL, 'cccc', NULL),
(105, NULL, 'gffdv', NULL),
(106, NULL, 'yrfc', NULL),
(107, NULL, 'ffff', NULL),
(108, NULL, 'ghyygv', NULL),
(109, NULL, '1234', NULL),
(110, NULL, '', NULL),
(111, NULL, 'GGGG', NULL),
(112, NULL, 'ffff', NULL),
(113, NULL, 'c3a6680c', NULL),
(114, NULL, 'azerty', NULL),
(115, NULL, '7a2eebae', NULL),
(116, NULL, '7a2eebae', NULL),
(117, NULL, 'aaf45db4', NULL),
(118, NULL, 'aaf45db4', NULL),
(119, NULL, '123456', NULL),
(120, NULL, '123456', NULL),
(121, NULL, '12345', NULL),
(122, NULL, '12345', NULL),
(123, NULL, 'azerty', NULL),
(124, NULL, 'azert', NULL),
(125, NULL, 'azerti', NULL),
(126, NULL, 'azertyu', NULL),
(127, NULL, 'azertyuio', NULL),
(128, NULL, 'azerty', NULL),
(129, NULL, '123456', NULL),
(130, NULL, 'azerty', NULL),
(131, NULL, 'azerty', NULL),
(132, NULL, 'azerty', NULL),
(133, NULL, 'azerty', NULL),
(134, NULL, 'azerty', NULL),
(135, NULL, '1234', NULL),
(136, NULL, '1234', NULL),
(137, NULL, '12345', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_salon`
--

CREATE TABLE `marketplace_salon` (
  `id` int NOT NULL,
  `titre` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `description` varchar(3000) COLLATE utf8mb3_unicode_ci NOT NULL,
  `date` date NOT NULL,
  `temps_debut` time NOT NULL,
  `temps_fin` time NOT NULL,
  `lieu` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `max_invitation` int NOT NULL,
  `affiche` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_session`
--

CREATE TABLE `marketplace_session` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `lot_id` int DEFAULT NULL,
  `datecreation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_session`
--

INSERT INTO `marketplace_session` (`id`, `user_id`, `lot_id`, `datecreation`) VALUES
(29, 51, NULL, '2023-10-20 02:25'),
(32, 39, NULL, '2023-10-20 03:05'),
(38, 40, NULL, '2023-10-20 09:19'),
(43, 39, 44, '2023-11-14 09:43'),
(44, 39, 63, '2023-11-15 15:32'),
(45, 51, 44, '2023-11-15 16:37'),
(46, 39, 52, '2023-11-16 15:01'),
(47, 39, 45, '2023-11-16 17:08'),
(48, 39, 46, '2023-11-16 20:02'),
(49, 39, 48, '2023-11-16 20:02'),
(50, 39, 51, '2023-11-16 21:07'),
(51, 39, 47, '2023-11-16 21:11'),
(52, 39, 49, '2023-11-16 21:14'),
(53, 38, 44, '2023-11-16 21:21'),
(54, 38, NULL, '2023-11-16 21:22'),
(55, 39, 50, '2023-11-20 08:46'),
(56, 39, 87, '2023-11-20 08:47'),
(57, 38, 45, '2023-11-20 09:33'),
(58, 40, 44, '2023-11-27 14:11'),
(59, 38, 79, '2023-12-28 01:02'),
(60, 39, 79, '2023-12-28 01:03'),
(61, 38, 46, '2023-12-28 02:50'),
(62, 114, NULL, '2024-12-16 10:24'),
(63, 114, 46, '2024-12-16 10:24'),
(64, 39, 55, '2024-12-16 17:29'),
(65, 115, NULL, '2024-12-18 22:11'),
(66, 115, 45, '2024-12-18 22:11'),
(67, 115, 46, '2024-12-18 22:15'),
(68, 38, 121, '2024-12-19 13:36'),
(69, 37, NULL, '2024-12-19 13:36'),
(70, 37, 121, '2024-12-19 13:36'),
(71, 38, 47, '2024-12-19 13:44'),
(72, 118, NULL, '2024-12-19 13:44'),
(73, 118, 47, '2024-12-19 13:44'),
(74, 38, 49, '2024-12-20 02:04'),
(75, 118, 49, '2024-12-20 13:48'),
(76, 117, NULL, '2024-12-20 13:49'),
(77, 117, 49, '2024-12-20 13:49'),
(78, 38, 50, '2024-12-20 14:10'),
(79, 118, 50, '2024-12-20 14:15'),
(80, 117, 50, '2024-12-20 14:17'),
(81, 38, 52, '2025-01-06 13:56'),
(82, 38, 119, '2025-01-14 16:21'),
(83, 118, 119, '2025-01-14 16:21'),
(84, 38, 118, '2025-01-14 16:35'),
(85, 118, 118, '2025-01-14 17:05'),
(86, 38, 117, '2025-01-14 17:24'),
(87, 118, 117, '2025-01-14 17:26'),
(88, 38, 116, '2025-01-15 01:43'),
(89, 118, 116, '2025-01-15 01:43'),
(90, 117, 116, '2025-01-15 01:44'),
(91, 38, 115, '2025-01-15 01:48'),
(92, 118, 115, '2025-01-15 11:06'),
(93, 38, 114, '2025-01-15 11:08'),
(94, 118, 114, '2025-01-15 11:10'),
(95, 38, 113, '2025-01-15 15:51'),
(96, 118, 113, '2025-01-15 15:53'),
(97, 118, 112, '2025-01-15 16:00'),
(98, 38, 112, '2025-02-03 02:23'),
(99, 38, 111, '2025-02-03 08:52'),
(100, 118, 111, '2025-02-04 13:28'),
(101, 38, 110, '2025-02-04 13:34'),
(102, 38, 123, '2025-02-04 13:54'),
(103, 128, 123, '2025-02-04 13:54'),
(104, 128, NULL, '2025-02-04 13:54'),
(105, 118, 110, '2025-02-05 04:15'),
(106, 38, 109, '2025-02-05 04:24'),
(107, 118, 109, '2025-02-05 04:24'),
(108, 38, 126, '2025-02-05 11:44'),
(109, 118, 126, '2025-02-05 11:44'),
(110, 37, 126, '2025-02-05 11:44'),
(111, 37, 125, '2025-02-05 12:12'),
(112, 37, 124, '2025-02-05 12:13'),
(113, 37, 128, '2025-02-05 12:32'),
(114, 38, 128, '2025-02-05 12:33'),
(115, 134, NULL, '2025-02-05 12:34'),
(116, 134, 128, '2025-02-05 12:34'),
(117, 132, NULL, '2025-02-05 12:37'),
(118, 132, 128, '2025-02-05 12:37'),
(119, 38, 130, '2025-02-05 12:45'),
(120, 134, 130, '2025-02-05 12:46'),
(121, 37, 130, '2025-02-05 12:46'),
(122, 38, 129, '2025-02-05 12:50'),
(123, 132, 129, '2025-02-05 12:50'),
(124, 37, 129, '2025-02-05 12:51'),
(125, 134, 129, '2025-02-05 12:51'),
(126, 37, 127, '2025-02-05 12:55'),
(127, 38, 124, '2025-02-07 09:02'),
(128, 134, 124, '2025-02-07 09:02'),
(129, 134, 127, '2025-02-07 09:11'),
(130, 134, 104, '2025-02-07 09:15'),
(131, 38, 127, '2025-02-10 02:03'),
(132, 38, 131, '2025-02-10 16:41'),
(133, 38, 132, '2025-02-10 16:46'),
(134, 134, 132, '2025-02-10 16:46'),
(135, 37, 131, '2025-02-10 16:58'),
(136, 134, 131, '2025-02-10 17:03'),
(137, 37, 108, '2025-02-11 01:35'),
(138, 118, 127, '2025-02-11 10:59'),
(139, 38, 133, '2025-02-11 11:28'),
(140, 118, 133, '2025-02-11 11:28'),
(141, 134, 133, '2025-02-11 11:28'),
(142, 38, 134, '2025-02-11 11:35'),
(143, 37, 137, '2025-02-12 08:56'),
(144, 118, 136, '2025-02-13 15:15'),
(145, 38, 136, '2025-02-13 15:15'),
(146, 118, 137, '2025-02-14 12:23'),
(147, 38, 137, '2025-02-18 09:16'),
(148, 38, 141, '2025-02-19 14:24'),
(149, 118, 141, '2025-02-19 14:26'),
(150, 38, 143, '2025-02-19 16:26'),
(151, 118, 143, '2025-02-19 16:28'),
(152, 137, NULL, '2025-02-19 23:45'),
(153, 137, 48, '2025-02-19 23:45'),
(154, 137, 141, '2025-02-20 00:17'),
(155, 38, 146, '2025-02-20 11:52'),
(156, 137, 146, '2025-02-20 11:52');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_subcomments`
--

CREATE TABLE `marketplace_subcomments` (
  `id` int NOT NULL,
  `comment_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `message` varchar(3000) COLLATE utf8mb3_unicode_ci NOT NULL,
  `date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_user`
--

CREATE TABLE `marketplace_user` (
  `id` int NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `roles` json NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `nom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `prenom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `telephone` int DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL,
  `is_blocked` tinyint(1) NOT NULL,
  `civilite` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `service` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `fonction` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `mobile` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `linkedin` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `facebook` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tweeter` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `photo` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `is_valid` tinyint(1) DEFAULT NULL,
  `adresse` varchar(55) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_user`
--

INSERT INTO `marketplace_user` (`id`, `email`, `roles`, `password`, `nom`, `prenom`, `telephone`, `is_verified`, `is_blocked`, `civilite`, `service`, `fonction`, `mobile`, `linkedin`, `facebook`, `tweeter`, `photo`, `is_valid`, `adresse`) VALUES
(37, 'lionardo@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$TElBTXJCdm9QLzRrbnBwOA$ZRWuHvoFrua2fbeaA4+HRWtsJd9WlZLKVMpfo2CBR4Y', 'Lionardo', 'Simoni', 99456706, 1, 0, 'Mr', 'direction commercial', 'commercial', '+39 370 143 546', 'LINKEDIN', 'undefined', 'TWEETER', 'bca621af9c258a46f18aafe28e1e14b9.jpeg', 1, NULL),
(38, 'admin@gmail.com', '[\"ROLE_ADMIN\"]', '$argon2id$v=19$m=65536,t=4,p=1$TElBTXJCdm9QLzRrbnBwOA$ZRWuHvoFrua2fbeaA4+HRWtsJd9WlZLKVMpfo2CBR4Y', 'Admin', 'Admin', 23456566, 1, 0, 'Mme', NULL, NULL, NULL, NULL, NULL, NULL, '720fd531a29ab9163a3a650cecef6348.png', NULL, 'bizerte'),
(118, 'lepecheur@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$+DZiPMLwwrntL8VsTcLzLw$3mjKnCIt+29/h+Jwpge8aLZf+7On6n8Ag5cDc0gdPEk', 'Syrine', 'Brik', 23689075, 1, 0, 'Mme', 'direction générale', 'directeur', NULL, NULL, NULL, NULL, NULL, 1, NULL),
(125, 'municipalité@gmail.com', '[\"ROLE_VISUALISATEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$TElBTXJCdm9QLzRrbnBwOA$ZRWuHvoFrua2fbeaA4+HRWtsJd9WlZLKVMpfo2CBR4Y', 'Tunis', 'Municipalité', 23456566, 1, 0, 'Mr', NULL, NULL, NULL, NULL, NULL, NULL, '720fd531a29ab9163a3a650cecef6348.png', 1, 'bizerte'),
(126, 'apip@gmail.com', '[\"ROLE_VISUALISATEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$TElBTXJCdm9QLzRrbnBwOA$ZRWuHvoFrua2fbeaA4+HRWtsJd9WlZLKVMpfo2CBR4Y', 'Tunis', 'Apip', 23456566, 1, 0, 'Mr', NULL, NULL, NULL, NULL, NULL, NULL, '720fd531a29ab9163a3a650cecef6348.png', 1, 'bizerte'),
(127, 'gipp@gmail.com', '[\"ROLE_VISUALISATEUR\"]', '$argon2id$v=19$m=65536,t=4,p=1$TElBTXJCdm9QLzRrbnBwOA$ZRWuHvoFrua2fbeaA4+HRWtsJd9WlZLKVMpfo2CBR4Y', 'Tunis', 'Gipp', 23456566, 1, 0, 'Mr', NULL, NULL, NULL, NULL, NULL, NULL, '720fd531a29ab9163a3a650cecef6348.png', 1, 'bizerte'),
(134, 'ing.dev.habib@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$u+pEZRdBmhMNdDjYjKWT1Q$kYQZ8++rsUJod2vOmVNTu8oeFwCRYCMFqPjp/XW/XOY', 'Mathlouthi', 'Habib', 97240582, 1, 0, 'Mr', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 'bizerte'),
(137, 'amenisyrine@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$qAJjMlHDmBGIh3InAsmtdQ$JvFlSrcYggxNpVXHzHSQ1dAUydFrlUiCen/EOggR2Ek', 'Brik', 'Syrine', 21096814, 1, 0, 'Mme', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 'Tunis');

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_vitirinaire`
--

CREATE TABLE `marketplace_vitirinaire` (
  `id` int NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `roles` json NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `nom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `prenom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `cin` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `matricule` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `port` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pays` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `wallet` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `mykeyss` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `telephone` int DEFAULT NULL,
  `is_valid` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Déchargement des données de la table `marketplace_vitirinaire`
--

INSERT INTO `marketplace_vitirinaire` (`id`, `email`, `roles`, `password`, `nom`, `prenom`, `cin`, `matricule`, `port`, `pays`, `wallet`, `mykeyss`, `telephone`, `is_valid`) VALUES
(2, 'briksyrine12@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$T1l4RlFtN2t0c2xFQWk4MA$HVtB0VMoGQ5RQFaZTny5pg1OQQUZUzQgoAPC1qOr9Js', 'iskander', 'jabri', '07961760', '123345', NULL, NULL, '0xcfB66c99172cc361A2B56461013491915eb655B8', '0xc71b6e1fd381d867706d7a435fb4ecbab3d31f46bbbf61c6c0865f636b15df23', 94586480, 1),
(3, 'jabriskander361@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$oqlzN3PjtIXMj/c6b+GW0A$uM+N3QA7wu2/6jsnVlvx1ckMYH4sSNYFyWm/EXpVyxM', 'iskander', 'jabri', '13098715', '123456', NULL, NULL, '0xcfB66c99172cc361A2B56461013491915eb655B8', '0xc71b6e1fd381d867706d7a435fb4ecbab3d31f46bbbf61c6c0865f636b15df23', 29082245, 1),
(4, 'mohamedjabri@gmial.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$DVCtZBl1LFPY8e6qDFxotQ$XcdWscioGkT9v/4WwdOHWZmRgKe3V32EOX9QWjaASR0', 'mohamed', 'jabri', '12345678', '1245', NULL, NULL, '0xcfB66c99172cc361A2B56461013491915eb655B8', '0xc71b6e1fd381d867706d7a435fb4ecbab3d31f46bbbf61c6c0865f636b15df23', 29631748, 1),
(5, 'hamajabri@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$zy/N+ItJaRG6VIkv7UYiCA$msxnakfPV6lHjpFeby+KWEYKucVddl+jOHel7HXiBAQ', 'hama', 'jabri', '12345678', '12m12', NULL, NULL, '0xcfB66c99172cc361A2B56461013491915eb655B8', '0xc71b6e1fd381d867706d7a435fb4ecbab3d31f46bbbf61c6c0865f636b15df23', 78963452, 1),
(6, 'mohamedvit@gmail.com', '[]', '$argon2id$v=19$m=65536,t=4,p=1$nAhidHsJrrmo0wQe+kkmZA$swhZv1ZQySwlpgUJ9q/u1tdc0e8TS4tvQm3sHin/wds', 'Ahmed Vet', 'bel arbi', '11223344', 'DDR42', NULL, NULL, '0x171e1cd2093039f27da2adc0a4bc2954adf0e683', '0x8e2d70e67829fbf151c93622001f94a137e024bae3e5587bf8cced6febd28946', 12345678, 1);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `marketplace_actualite`
--
ALTER TABLE `marketplace_actualite`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `marketplace_administrateur`
--
ALTER TABLE `marketplace_administrateur`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQ_66E1794FE7927C74` (`email`);

--
-- Index pour la table `marketplace_annonce`
--
ALTER TABLE `marketplace_annonce`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_ED5300E9A76ED395` (`user_id`);

--
-- Index pour la table `marketplace_aommande`
--
ALTER TABLE `marketplace_aommande`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQ_382A1B9CAEA34913` (`reference`),
  ADD KEY `IDX_382A1B9CA76ED395` (`user_id`),
  ADD KEY `IDX_382A1B9C670C757F` (`fournisseur_id`);

--
-- Index pour la table `marketplace_avis`
--
ALTER TABLE `marketplace_avis`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_9DEA8196F347EFB` (`produit_id`),
  ADD KEY `IDX_9DEA8196A76ED395` (`user_id`);

--
-- Index pour la table `marketplace_categorie`
--
ALTER TABLE `marketplace_categorie`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `marketplace_categorie_comment`
--
ALTER TABLE `marketplace_categorie_comment`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `marketplace_commande_equipement`
--
ALTER TABLE `marketplace_commande_equipement`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQ_46029C2AAEA34913` (`reference`),
  ADD KEY `IDX_46029C2AA76ED395` (`user_id`),
  ADD KEY `IDX_46029C2A670C757F` (`fournisseur_id`);

--
-- Index pour la table `marketplace_comments`
--
ALTER TABLE `marketplace_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_4B7B2CB629CCBAD0` (`forum_id`),
  ADD KEY `IDX_4B7B2CB6A76ED395` (`user_id`);

--
-- Index pour la table `marketplace_contact`
--
ALTER TABLE `marketplace_contact`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `marketplace_country`
--
ALTER TABLE `marketplace_country`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `marketplace_engene`
--
ALTER TABLE `marketplace_engene`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `marketplace_entreprise`
--
ALTER TABLE `marketplace_entreprise`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQ_FB597101A76ED395` (`user_id`);

--
-- Index pour la table `marketplace_equipement`
--
ALTER TABLE `marketplace_equipement`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_4EF44D92A76ED395` (`user_id`);

--
-- Index pour la table `marketplace_equipementvendus`
--
ALTER TABLE `marketplace_equipementvendus`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_D3FC7E76E0C8CDBE` (`commandeequipement_id`),
  ADD KEY `IDX_D3FC7E76806F0F5C` (`equipement_id`);

--
-- Index pour la table `marketplace_espece`
--
ALTER TABLE `marketplace_espece`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `marketplace_forum`
--
ALTER TABLE `marketplace_forum`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_21E8018AA76ED395` (`user_id`),
  ADD KEY `IDX_21E8018ABCF5E72D` (`categorie_id`);

--
-- Index pour la table `marketplace_image`
--
ALTER TABLE `marketplace_image`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_61FEBB18F347EFB` (`produit_id`);

--
-- Index pour la table `marketplace_image_equipement`
--
ALTER TABLE `marketplace_image_equipement`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_FBA9DBE6F347EFB` (`produit_id`);

--
-- Index pour la table `marketplace_lots`
--
ALTER TABLE `marketplace_lots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_831BADA8B6F45065` (`prise_id`),
  ADD KEY `IDX_831BADA8A76ED395` (`user_id`),
  ADD KEY `IDX_831BADA881509B71` (`rfid_id`) USING BTREE,
  ADD KEY `IDX_831BADA895682218` (`vitirinaire_id`) USING BTREE;

--
-- Index pour la table `marketplace_maryeur`
--
ALTER TABLE `marketplace_maryeur`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQ_67393569E7927C74` (`email`);

--
-- Index pour la table `marketplace_message`
--
ALTER TABLE `marketplace_message`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_525BE363F624B39D` (`sender_id`),
  ADD KEY `IDX_525BE363CD53EDB6` (`receiver_id`);

--
-- Index pour la table `marketplace_panier`
--
ALTER TABLE `marketplace_panier`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_23FA7AA7F347EFB` (`produit_id`),
  ADD KEY `IDX_23FA7AA7A76ED395` (`user_id`);

--
-- Index pour la table `marketplace_panier_equipement`
--
ALTER TABLE `marketplace_panier_equipement`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_96F3A0A0806F0F5C` (`equipement_id`),
  ADD KEY `IDX_96F3A0A0A76ED395` (`user_id`);

--
-- Index pour la table `marketplace_pecheur`
--
ALTER TABLE `marketplace_pecheur`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQ_4F8404B9E7927C74` (`email`);

--
-- Index pour la table `marketplace_picture`
--
ALTER TABLE `marketplace_picture`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_F23D9C9538B217A7` (`publication_id`);

--
-- Index pour la table `marketplace_prise`
--
ALTER TABLE `marketplace_prise`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_DBB97C8CD43709BC` (`pecheur_id`),
  ADD KEY `IDX_DBB97C8C2A33F427` (`maryeur_id`);

--
-- Index pour la table `marketplace_produit`
--
ALTER TABLE `marketplace_produit`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_CD433F3BBCF5E72D` (`categorie_id`),
  ADD KEY `IDX_CD433F3BA76ED395` (`user_id`);

--
-- Index pour la table `marketplace_produitvendus`
--
ALTER TABLE `marketplace_produitvendus`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_6F12D34282EA2E54` (`commande_id`),
  ADD KEY `IDX_6F12D342F347EFB` (`produit_id`);

--
-- Index pour la table `marketplace_publication`
--
ALTER TABLE `marketplace_publication`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_957F763CA76ED395` (`user_id`);

--
-- Index pour la table `marketplace_reservation`
--
ALTER TABLE `marketplace_reservation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_2B749E2E4C91BDE4` (`salon_id`),
  ADD KEY `IDX_2B749E2EA76ED395` (`user_id`);

--
-- Index pour la table `marketplace_rfid`
--
ALTER TABLE `marketplace_rfid`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_3F2A6C89D43709BC` (`pecheur_id`);

--
-- Index pour la table `marketplace_salon`
--
ALTER TABLE `marketplace_salon`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `marketplace_session`
--
ALTER TABLE `marketplace_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_34A206C8A76ED395` (`user_id`),
  ADD KEY `IDX_34A206C8A8CBA5F7` (`lot_id`);

--
-- Index pour la table `marketplace_subcomments`
--
ALTER TABLE `marketplace_subcomments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `IDX_3DB2FCD8F8697D13` (`comment_id`),
  ADD KEY `IDX_3DB2FCD8A76ED395` (`user_id`);

--
-- Index pour la table `marketplace_user`
--
ALTER TABLE `marketplace_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQ_9FE8FC2FE7927C74` (`email`);

--
-- Index pour la table `marketplace_vitirinaire`
--
ALTER TABLE `marketplace_vitirinaire`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQ_9E09863CE7927C74` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `marketplace_actualite`
--
ALTER TABLE `marketplace_actualite`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `marketplace_administrateur`
--
ALTER TABLE `marketplace_administrateur`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `marketplace_annonce`
--
ALTER TABLE `marketplace_annonce`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `marketplace_aommande`
--
ALTER TABLE `marketplace_aommande`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;

--
-- AUTO_INCREMENT pour la table `marketplace_avis`
--
ALTER TABLE `marketplace_avis`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `marketplace_categorie`
--
ALTER TABLE `marketplace_categorie`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `marketplace_categorie_comment`
--
ALTER TABLE `marketplace_categorie_comment`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pour la table `marketplace_commande_equipement`
--
ALTER TABLE `marketplace_commande_equipement`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `marketplace_comments`
--
ALTER TABLE `marketplace_comments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT pour la table `marketplace_contact`
--
ALTER TABLE `marketplace_contact`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT pour la table `marketplace_country`
--
ALTER TABLE `marketplace_country`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1097;

--
-- AUTO_INCREMENT pour la table `marketplace_engene`
--
ALTER TABLE `marketplace_engene`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `marketplace_entreprise`
--
ALTER TABLE `marketplace_entreprise`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT pour la table `marketplace_equipement`
--
ALTER TABLE `marketplace_equipement`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT pour la table `marketplace_equipementvendus`
--
ALTER TABLE `marketplace_equipementvendus`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `marketplace_espece`
--
ALTER TABLE `marketplace_espece`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT pour la table `marketplace_forum`
--
ALTER TABLE `marketplace_forum`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `marketplace_image`
--
ALTER TABLE `marketplace_image`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT pour la table `marketplace_image_equipement`
--
ALTER TABLE `marketplace_image_equipement`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `marketplace_lots`
--
ALTER TABLE `marketplace_lots`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=147;

--
-- AUTO_INCREMENT pour la table `marketplace_maryeur`
--
ALTER TABLE `marketplace_maryeur`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `marketplace_message`
--
ALTER TABLE `marketplace_message`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=120;

--
-- AUTO_INCREMENT pour la table `marketplace_panier`
--
ALTER TABLE `marketplace_panier`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `marketplace_panier_equipement`
--
ALTER TABLE `marketplace_panier_equipement`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `marketplace_pecheur`
--
ALTER TABLE `marketplace_pecheur`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT pour la table `marketplace_picture`
--
ALTER TABLE `marketplace_picture`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `marketplace_prise`
--
ALTER TABLE `marketplace_prise`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=164;

--
-- AUTO_INCREMENT pour la table `marketplace_produit`
--
ALTER TABLE `marketplace_produit`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT pour la table `marketplace_produitvendus`
--
ALTER TABLE `marketplace_produitvendus`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT pour la table `marketplace_publication`
--
ALTER TABLE `marketplace_publication`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `marketplace_reservation`
--
ALTER TABLE `marketplace_reservation`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `marketplace_rfid`
--
ALTER TABLE `marketplace_rfid`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=138;

--
-- AUTO_INCREMENT pour la table `marketplace_salon`
--
ALTER TABLE `marketplace_salon`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `marketplace_session`
--
ALTER TABLE `marketplace_session`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=157;

--
-- AUTO_INCREMENT pour la table `marketplace_subcomments`
--
ALTER TABLE `marketplace_subcomments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `marketplace_user`
--
ALTER TABLE `marketplace_user`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=138;

--
-- AUTO_INCREMENT pour la table `marketplace_vitirinaire`
--
ALTER TABLE `marketplace_vitirinaire`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
