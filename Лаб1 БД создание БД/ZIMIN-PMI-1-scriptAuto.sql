USE [master]
GO
/****** Object:  Database [Автомобили]    Script Date: 16.01.2018 9:26:32 ******/
CREATE DATABASE [Автомобили]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Автомобили', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\Автомобили.mdf' , SIZE = 4160KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Автомобили_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\Автомобили_log.ldf' , SIZE = 1040KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Автомобили] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Автомобили].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Автомобили] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Автомобили] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Автомобили] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Автомобили] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Автомобили] SET ARITHABORT OFF 
GO
ALTER DATABASE [Автомобили] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [Автомобили] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Автомобили] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Автомобили] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Автомобили] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Автомобили] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Автомобили] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Автомобили] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Автомобили] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Автомобили] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Автомобили] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Автомобили] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Автомобили] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Автомобили] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Автомобили] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Автомобили] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Автомобили] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Автомобили] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Автомобили] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Автомобили] SET  MULTI_USER 
GO
ALTER DATABASE [Автомобили] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Автомобили] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Автомобили] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Автомобили] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [Автомобили]
GO
/****** Object:  Table [dbo].[Марки автомобилей]    Script Date: 16.01.2018 9:26:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Марки автомобилей](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Название марки] [nvarchar](50) NOT NULL,
	[Год основания] [int] NULL,
	[idСтраны-производителя] [int] NOT NULL,
 CONSTRAINT [PK_Марки автомобилей] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Модели автомобилей]    Script Date: 16.01.2018 9:26:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Модели автомобилей](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Название модели] [nvarchar](50) NOT NULL,
	[Год основания] [int] NULL,
	[idМарки автомобиля] [int] NOT NULL,
 CONSTRAINT [PK_Модели автомобилей] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Страны производители]    Script Date: 16.01.2018 9:26:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Страны производители](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Страна производитель] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Страны производители] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Марки автомобилей] ON 

INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (1, N'Toyota', 1937, 1)
INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (2, N'Honda', 1948, 1)
INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (3, N'Mitsubishi', 1870, 1)
INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (4, N'Lada', 1966, 2)
INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (5, N'УАЗ', 1992, 2)
INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (6, N'Citroen', 1919, 3)
INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (7, N'Renault', 1899, 3)
INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (8, N'Peugeot', 1882, 3)
INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (9, N'Volkswagen', 1937, 4)
INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (10, N'Audi', 1909, 4)
INSERT [dbo].[Марки автомобилей] ([id], [Название марки], [Год основания], [idСтраны-производителя]) VALUES (11, N'BMW', 1916, 4)
SET IDENTITY_INSERT [dbo].[Марки автомобилей] OFF
SET IDENTITY_INSERT [dbo].[Модели автомобилей] ON 

INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (1, N'Land Crouser', 1996, 1)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (2, N'Camry', 2001, 1)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (3, N'Civic', 2001, 2)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (4, N'JAZZ', 2002, 2)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (5, N'Lancer', 2003, 3)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (6, N'Galant', 1997, 3)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (7, N'Grandis', 1996, 3)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (8, N'Vesta', 2015, 4)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (9, N'XRAY', 2015, 4)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (10, N'4x4', 1995, 4)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (11, N'2104', 1984, 4)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (12, N'Patriot', 2010, 5)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (13, N'PICKUP', 2010, 5)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (14, N'C5', 2001, 6)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (15, N'C4 Sedan', 2013, 6)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (16, N'Berlingo', 2008, 6)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (17, N'CLIO ', 2001, 7)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (18, N'Megane', 1999, 7)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (19, N'206', 1998, 8)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (20, N'3008', 2010, 8)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (21, N'Jetta', 2005, 9)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (22, N'BIORA', 2013, 9)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (23, N'A1', 2011, 10)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (24, N'RS6', 2002, 10)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (25, N'X6', 2008, 11)
INSERT [dbo].[Модели автомобилей] ([id], [Название модели], [Год основания], [idМарки автомобиля]) VALUES (26, N'1 series', 2001, 11)
SET IDENTITY_INSERT [dbo].[Модели автомобилей] OFF
SET IDENTITY_INSERT [dbo].[Страны производители] ON 

INSERT [dbo].[Страны производители] ([id], [Страна производитель]) VALUES (1, N'Япония')
INSERT [dbo].[Страны производители] ([id], [Страна производитель]) VALUES (2, N'Россия')
INSERT [dbo].[Страны производители] ([id], [Страна производитель]) VALUES (3, N'Франция')
INSERT [dbo].[Страны производители] ([id], [Страна производитель]) VALUES (4, N'Германия')
INSERT [dbo].[Страны производители] ([id], [Страна производитель]) VALUES (5, N'Китай')
SET IDENTITY_INSERT [dbo].[Страны производители] OFF
ALTER TABLE [dbo].[Марки автомобилей]  WITH CHECK ADD  CONSTRAINT [FK_Марки автомобилей_Страны производители] FOREIGN KEY([idСтраны-производителя])
REFERENCES [dbo].[Страны производители] ([id])
GO
ALTER TABLE [dbo].[Марки автомобилей] CHECK CONSTRAINT [FK_Марки автомобилей_Страны производители]
GO
ALTER TABLE [dbo].[Модели автомобилей]  WITH CHECK ADD  CONSTRAINT [FK_Модели автомобилей_Марки автомобилей] FOREIGN KEY([idМарки автомобиля])
REFERENCES [dbo].[Марки автомобилей] ([id])
GO
ALTER TABLE [dbo].[Модели автомобилей] CHECK CONSTRAINT [FK_Модели автомобилей_Марки автомобилей]
GO
USE [master]
GO
ALTER DATABASE [Автомобили] SET  READ_WRITE 
GO
