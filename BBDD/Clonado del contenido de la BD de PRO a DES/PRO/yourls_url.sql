/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.6-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: yourls
-- ------------------------------------------------------
-- Server version	11.8.6-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `yourls_url`
--

DROP TABLE IF EXISTS `yourls_url`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `yourls_url` (
  `keyword` varchar(200) NOT NULL,
  `url` text NOT NULL,
  `title` text DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT current_timestamp(),
  `clicks` int(11) DEFAULT 0,
  PRIMARY KEY (`keyword`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `yourls_url`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `yourls_url` WRITE;
/*!40000 ALTER TABLE `yourls_url` DISABLE KEYS */;
INSERT INTO `yourls_url` VALUES
('agricultura','https://www.juntadeandalucia.es/agriculturaypesca','Consejería de Agricultura','2026-02-25 08:28:34',88),
('boja','https://www.juntadeandalucia.es/boja','BOJA Oficial','2026-02-25 08:28:34',176),
('contratacion','https://contratacion.juntadeandalucia.es','Plataforma de Contratación','2026-02-25 08:28:34',87),
('correo','https://correo.juntadeandalucia.es','Correo Corporativo','2026-02-25 08:28:34',210),
('cultura','https://www.juntadeandalucia.es/cultura','Consejería de Cultura','2026-02-25 08:28:34',67),
('digital','https://www.juntadeandalucia.es/transformacioneconomica','Transformación Digital','2026-02-25 08:28:34',59),
('educacion','https://www.juntadeandalucia.es/educacion','Consejería de Educación','2026-02-25 08:28:34',165),
('empleo','https://www.juntadeandalucia.es/empleo','Consejería de Empleo','2026-02-25 08:28:34',134),
('familia','https://www.juntadeandalucia.es/igualdadypoliticassociales','Políticas Sociales','2026-02-25 08:28:34',92),
('hacienda','https://www.juntadeandalucia.es/haciendayfinanciacioneuropea','Consejería de Hacienda','2026-02-25 08:28:34',154),
('intranet','https://intranet.juntadeandalucia.es','Intranet Corporativa','2026-02-25 08:28:34',145),
('justicia','https://www.juntadeandalucia.es/justicia','Consejería de Justicia','2026-02-25 08:28:34',112),
('medioambiente','https://www.juntadeandalucia.es/medioambiente','Consejería de Medio Ambiente','2026-02-25 08:28:34',73),
('movilidad','https://www.juntadeandalucia.es/fomentoyvivienda','Fomento y Vivienda','2026-02-25 08:28:34',81),
('participa','https://participa.juntadeandalucia.es','Portal de Participación Ciudadana','2026-02-25 08:28:34',44),
('rrhh','https://rrhh.juntadeandalucia.es','Portal Recursos Humanos','2026-02-25 08:28:34',98),
('salud','https://www.sspa.juntadeandalucia.es','Servicio Andaluz de Salud','2026-02-25 08:28:34',199),
('sede','https://sede.juntadeandalucia.es','Sede Electrónica','2026-02-25 08:28:34',340),
('transparencia','https://transparencia.juntadeandalucia.es','Portal de Transparencia','2026-02-25 08:28:34',120),
('turismo','https://www.andalucia.org','Turismo de Andalucía','2026-02-25 08:28:34',256);
/*!40000 ALTER TABLE `yourls_url` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-02-25  8:33:26
