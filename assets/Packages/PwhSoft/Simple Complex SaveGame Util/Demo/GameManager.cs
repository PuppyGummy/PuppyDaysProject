using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using PWHSoftSaveGame;
using UnityEngine;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    #region Serializable Fields

    [SerializeField] private Text _statusTextField;
    [SerializeField] private GameObject _player;

    #endregion

    #region Private Members

    private TestSaveGameModel _saveGame;

    #endregion

    #region Save, Load, Restart

    public void Load()
    {
        _saveGame = SaveGameUtil.Load<TestSaveGameModel>();

        if (_saveGame == null)
        {
            _saveGame = SetupComplexSaveGame();
            
            PrintStatus("Setup new savegame!");
            
            SaveTheGame();
        }
        else
        {
            PrintStatus("Loaded!");
        }
        
        SetPlayerPosition(_saveGame.PlayerSaveGame.Location);
    }
    
    public void SaveTheGame()
    {
        //Save the save game async
        SaveGameUtil.SaveAsync(_saveGame, () =>
            {
                Debug.Log("The savegame was saved.");
                PrintStatus("Saved!");
            },
            exception =>
            {
                Debug.LogError(exception.Message);
                PrintStatus("The game could not be saved.");
            });
    }

    public void Restart()
    {
        StartCoroutine(RestartAsync());
    }

    private IEnumerator RestartAsync()
    {
        _saveGame = null;
        PrintStatus("Unloaded the savegame");

        yield return new WaitForSeconds(1);
        
        Load();
    }

    #endregion

    #region Init

    // Start is called before the first frame update
    void Start()
    {
        //Init the save game util.
        SaveGameUtil.Init();
        
        //Enable Encryption
        SaveGameUtil.EnableEncryption("123456");
        
        //Sets the subfolder within the Persistent application path.
        SaveGameUtil.SetSaveFilesSubFolder(Path.Combine("savegames","main"));
        
        //Sets the file extension for the savegames.
        SaveGameUtil.SetSaveFilesExtension("secretsavefile");
        
        //Check encryption is enabled
        if (SaveGameUtil.IsEncryptionEnabled)
            Debug.Log("The save game is protected.");
        
        //Register the save game class
        SaveGameUtil.RegisterSaveFileModel<TestSaveGameModel>("mainsavegame");


        //Check for save game exists
        var saveGameName = SaveGameUtil.GetSaveGameName<TestSaveGameModel>();
        if (saveGameName == null)
        {
            Debug.Log("No save game...");
        }
        else
        {
            Debug.Log("The save game name for the model " + nameof(TestSaveGameModel) + " is " + saveGameName);
        }
        
        //Load the savegame using method
        Load();
        
/*
        //Setup up a save game
        TestSaveGameModel saveGame = SetupComplexSaveGame();
        saveGame.TestDictionary.Add("test", "test");
        saveGame.ComplexTestDictionary.Add("test2", new TestSaveGameModelComplexTest()
        {
            Id = 4
        });
        
        //Save some to the save game class
        SaveGameUtil.Save(saveGame);
        Debug.Log("Saved SaveGame");
        
        //Load save game async
        SaveGameUtil.LoadAsync<TestSaveGameModel>(loadedSaveGame =>
        {
            _saveGame = loadedSaveGame;
            Debug.Log("The save game was loaded");
        }, onFailure: exception =>
        {
            Debug.LogError(exception.Message);
        });
        
        //Save the save game async
        SaveGameUtil.SaveAsync(saveGame, () => Debug.Log("The savegame was saved."),
            exception => Debug.LogError(exception.Message));*/
    }
    
    #endregion
    
    
    // Update is called once per frame
    void Update()
    {
        
    }

    public void DeleteSaveGame()
    {
        //Delete Save Game
        SaveGameUtil.Delete<TestSaveGameModel>();
        
        PrintStatus("Deleted");
    }

    #region Complex Savegame model handling

    private static TestSaveGameModel SetupComplexSaveGame()
    {

        //Create a model
        var saveGame = new TestSaveGameModel
        {
            Activated = true,
            ComplexTestDictionary = new Dictionary<string, TestSaveGameModelComplexTest>(),
            CreateDateTime = DateTime.Now,
            Name = "mainSaveGame",
            Id = 1,
            TestDictionary = new Dictionary<string, string>(),
            StringArray = new List<string>() { "test" },
            PlayerSaveGame = PlayerSaveGameModel.CreateDefault()
        };
        saveGame.ComplexList = new List<TestSaveGameModelComplexTest>
        {
            new TestSaveGameModelComplexTest()
            {
                Id = 1,
                IsDetail = false,
                Name = "TestEntry1",
                Parent = saveGame,
                ComplexList = new List<TestSaveGameModelComplexTestSub>
                {
                    new TestSaveGameModelComplexTestSub
                    {
                        Identity = "1",
                        Position = Vector3.down
                    },

                    new TestSaveGameModelComplexTestSub
                    {
                        Identity = "2",
                        Position = Vector3.up
                    }
                }
            },
            new TestSaveGameModelComplexTest()
            {
                Id = 2,
                IsDetail = true,
                Name = "TestEntry2",
                Parent = saveGame,
                ComplexList = new List<TestSaveGameModelComplexTestSub>
                {
                    new TestSaveGameModelComplexTestSub
                    {
                        Identity = "2",
                        Position = Vector3.down
                    },

                    new TestSaveGameModelComplexTestSub
                    {
                        Identity = "3",
                        Position = Vector3.right
                    }
                }
            }
        };
        return saveGame;
    }


    #region Save Game Model Classes

    public class TestSaveGameModel
    {
        public string Name { get; set; }
        public int Id { get; set; }
        public bool Activated { get; set; }
        public DateTime CreateDateTime { get; set; }
        public Dictionary<string, string> TestDictionary { get; set; }
        public Dictionary<string, TestSaveGameModelComplexTest> ComplexTestDictionary { get; set; }
        public List<string> StringArray { get; set; }
        public List<TestSaveGameModelComplexTest> ComplexList { get; set; }
        
        public PlayerSaveGameModel PlayerSaveGame { get; set; }
    }

    public class PlayerSaveGameModel
    {
        /// <summary>
        /// Creates the default player savegame model
        /// </summary>
        /// <returns></returns>
        public static PlayerSaveGameModel CreateDefault()
        {
            var defaultSaveState = new PlayerSaveGameModel()
            {
                Location = Vector3.zero,
            };
            return defaultSaveState;
        }
        
        public PlayerSaveGameModel() {}
        
        public Vector3 Location { get; set; }
    }

    public class TestSaveGameModelComplexTest
    {
        public string Name { get; set; }
        public int Id { get; set; }
        public bool IsDetail { get; set; }

        public TestSaveGameModel Parent { get; set; }

        //Do never use standard arrays --> instead use lists
        public List<TestSaveGameModelComplexTestSub> ComplexList { get; set; }
    }

    public class TestSaveGameModelComplexTestSub
    {
        public Vector3 Position { get; set; }

        public string Identity { get; set; }
    }

    #endregion
    #endregion

    #region Helper

    
    private void PrintStatus(string status)
    {
        if (_statusTextField == null)
            throw new NullReferenceException(nameof(_statusTextField) + " not set!");

        _statusTextField.text = status ?? string.Empty;
    }

    #endregion

    #region Control the game

    /// <summary>
    /// Moves the player by pixels
    /// </summary>
    /// <param name="direction">The direction to move the player to.</param>
    public void MovePlayer(Vector3 direction)
    {
        if (_player == null)
            throw new NullReferenceException(nameof(_player) + " not set.");

        var currentPosition = _player.transform.localPosition;
        var targetPosition = currentPosition + direction * 10f;

        SetPlayerPosition(targetPosition);
    }

    /// <summary>
    /// Sets the player positon
    /// </summary>
    /// <param name="position"></param>
    public void SetPlayerPosition(Vector3 position)
    {
        if (_player == null)
            throw new NullReferenceException(nameof(_player) + " not set.");
        
        if (_saveGame == null)
            Load();
        
        _saveGame.PlayerSaveGame.Location = position;
        _player.transform.localPosition = position;
    }

    public void GoLeft()
    {
        MovePlayer(Vector3.left);
    }
    
    public void GoUp()
    {
        MovePlayer(Vector3.up);
    }
    
    public void GoDown()
    {
        MovePlayer(Vector3.down);
    }
    
    public void GoRight()
    {
        MovePlayer(Vector3.right);
    }

    #endregion
}
