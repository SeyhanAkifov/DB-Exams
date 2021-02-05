CREATE DATABASE [Colonial Journey]

CREATE TABLE Planets
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL
);

CREATE TABLE Spaceports
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
PlanetId INT NOT NULL,
FOREIGN KEY (PlanetId) REFERENCES Planets(Id)
);

CREATE TABLE Spaceships
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Manufacturer VARCHAR(50) NOT NULL,
LightSpeedRate INT DEFAULT 0
);

CREATE TABLE Colonists
(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(20) NOT NULL,
Ucn VARCHAR(10) NOT NULL UNIQUE,
BirthDate DATE NOT NULL 
);

CREATE TABLE Journeys
(
Id INT PRIMARY KEY IDENTITY,
JourneyStart DATETIME NOT NULL,
JourneyEnd DATETIME NOT NULL,
Purpose VARCHAR(11)  CHECK(Purpose='Medical'OR Purpose='Technical' OR Purpose='Educational' OR Purpose='Military' ),
DestinationSpaceportId INT NOT NULL ,
SpaceshipId INT NOT NULL ,
FOREIGN KEY (DestinationSpaceportId) REFERENCES Spaceports(Id),
FOREIGN KEY (SpaceshipId) REFERENCES Spaceships(Id),
   
);

CREATE TABLE TravelCards
(
Id INT PRIMARY KEY IDENTITY,
CardNumber VARCHAR(10) NOT NULL UNIQUE,
JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney='Pilot'OR JobDuringJourney='Engineer' OR JobDuringJourney='Trooper' OR JobDuringJourney='Cleaner' OR JobDuringJourney = 'Cook' ),
ColonistId INT NOT NULL ,
JourneyId INT NOT NULL ,
FOREIGN KEY (ColonistId) REFERENCES Colonists(Id),
FOREIGN KEY (JourneyId) REFERENCES Journeys(Id),
);


--2. Insert

INSERT   INTO  Planets ([Name])
VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn');


INSERT   INTO  Spaceships ([Name], Manufacturer, LightSpeedRate)
VALUES
('Golf', 'VW', 3),
('WakaWaka', 'Wakanda', 4),
('Falcon9', 'SpaceX', 1),
('Bed', 'Vidolov', 6);

--3. Update

UPDATE Spaceships
SET LightSpeedRate =   LightSpeedRate  + 1
WHERE Id BETWEEN 8 AND 12


--4. Delete

DELETE FROM TravelCards
WHERE JourneyId BETWEEN 1 AND 3

DELETE TOP (3)  FROM Journeys

--05. Select All Military Journeys

SELECT Id, FORMAT(JourneyStart, 'dd/MM/yyyy'), FORMAT(JourneyEnd, 'dd/MM/yyyy') FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart


--6. Select All Pilots

SELECT Colonists.Id, CONCAT(FirstName, ' ', LastName) AS [full_name] FROM Colonists
JOIN TravelCards ON TravelCards.ColonistId = Colonists.Id
WHERE TravelCards.JobDuringJourney = 'Pilot'
ORDER BY Colonists.Id

--7. Count Colonists

SELECT COUNT(*) AS [count] FROM Colonists
JOIN TravelCards ON TravelCards.ColonistId = Colonists.Id
JOIN Journeys ON Journeys.Id = TravelCards.JourneyId
WHERE Journeys.Purpose = 'Technical'

--8. Select Spaceships With Pilots

SELECT Spaceships.[Name], Manufacturer FROM Colonists
JOIN TravelCards ON TravelCards.ColonistId = Colonists.Id
JOIN Journeys ON Journeys.Id = TravelCards.JourneyId
JOIN Spaceships ON Spaceships.Id = Journeys.SpaceshipId
WHERE TravelCards.JobDuringJourney = 'Pilot' AND Colonists.BirthDate >= '01/01/1990'
ORDER BY Spaceships.[Name]

--9.Select all planets and their journey count


SELECT p.[Name] AS [PlanetName], SUM(JCount) AS [JourneyCount]FROM
(
SELECT Journeys.DestinationSpaceportId, Count(*) [JCount], Spaceports.PlanetId, Planets.[Name] FROM Journeys
JOIN Spaceports ON Spaceports.Id = Journeys.DestinationSpaceportId
JOIN Planets ON Planets.Id = Spaceports.PlanetId
GROUP BY  Spaceports.PlanetId,Journeys.DestinationSpaceportId , Planets.[Name]
) AS p
GROUP BY p.[Name], JCount 
ORDER BY JourneyCount DESC, P.[Name]

--10. Select Special Colonists


SELECT * FROM (
SELECT w.JobDuringJourney, CONCAT(w.FirstName, ' ', w.LastName) AS [FullName],
DENSE_RANK () OVER ( Partition BY w.JobDuringJourney
		ORDER BY w.BirthDate ASC
	) AS Rank
	
FROM
(
SELECT JobDuringJourney, FirstName, LastName, BirthDate FROM Colonists
JOIN TravelCards ON TravelCards.ColonistId = Colonists.Id
GROUP BY JobDuringJourney, FirstName, LastName, BirthDate
)As w
)AS s
WHERE s.Rank = 2

--11.	Get Colonists Count

CREATE FUNCTION dbo.udf_GetColonistsCount(@PlanetName VARCHAR (30)) 
RETURNS INT
AS
BEGIN
DECLARE @Result INT 

SET @Result  = (SELECT COUNT(*)AS [Count] FROM Colonists
  JOIN TravelCards ON TravelCards.ColonistId = Colonists.Id
  JOIN Journeys ON Journeys.Id = TravelCards.JourneyId
  JOIN Spaceports ON Spaceports.Id = Journeys.DestinationSpaceportId
  JOIN Planets ON Planets.Id = Spaceports.PlanetId
  WHERE Planets.[Name] = @PlanetName)
  
  RETURN @Result
  END
  

 SELECT dbo.udf_GetColonistsCount('Otroyphus') AS [COUNT]

 --12. Change Journey Purpose

 CREATE PROCEDURE usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
 AS
 BEGIN

   IF NOT EXISTS (
   SELECT * FROM Journeys
   WHERE Id = @JourneyId
   )
   BEGIN
   RAISERROR ('The journey does not exist!',16,1)
   END

   DECLARE @CurrPurpose VARCHAR(11) = (SELECT Purpose FROM Journeys
   WHERE Id = @JourneyId)

   IF (@CurrPurpose = @NewPurpose)
   BEGIN
   RAISERROR ('You cannot change the purpose!', 16,1)
   END

   UPDATE Journeys
   SET Purpose = @NewPurpose
   WHERE Id = @JourneyId

 END



 SELECT * FROM Journeys














