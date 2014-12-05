//
//  gameListViewController.m
//  OraChat
//
//  Created by Colin on 11/22/14.
//  Copyright (c) 2014 Colin Gorman. All rights reserved.
//

#import "gameListViewController.h"
#import "getDataFromOra.h"
#import "MatchViewController.h"
#import "challengeViewController.h"

@interface gameListViewController ()

@property (nonatomic) NSMutableArray *gameListData;
@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) getDataFromOra *oraGetGameList;
@property (strong, nonatomic) NSString *messageForGame;
@property (strong, nonatomic) NSString *messageWordForGame;
@property (strong, nonatomic) NSString *chatIDForGame;

@end

@implementation gameListViewController

- (void)viewDidLoad
{
    //on view load get list of games andcall build view
    [self getListOfGames];
    [self buildView];
}

-(void) getListOfGames
{
    //build of dictionary for json submission
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:[NSString stringWithFormat:@"%@",[_userDict valueForKey:@"user_token"]] forKey:@"user_token"];
    //unable to test any query logic currently as I am unable to register users
    [jsonDictionary setObject:@"" forKey:@"query"];
    [jsonDictionary setObject:@"1" forKey:@"page"];
    [jsonDictionary setObject:@"30" forKey:@"limit"];
    //intialize class getDataFromOra for json submission
    _oraGetGameList = [[getDataFromOra alloc]init];
    //call the json submission method
    NSDictionary *results = [_oraGetGameList postToOra:@"/api/chats.json" :jsonDictionary];
    //check returned dictionary exists and there was no error during post
    if (results && [[results valueForKey:@"error"]isEqualToString:@"YES"]) {
        //clear out error label, store userData, perform segue to take user to list of games
        NSLog(@"%@",[results valueForKey:@"error"]);
        /*
         Test data below when unable to connect to server
         */
        _gameListData = [NSMutableArray arrayWithObjects:@"game1", @"game2", @"game3", @"game4", @"game5", @"game6", @"game7", @"game8", @"game9", @"game10", @"game11", @"game12", @"game13", @"game14", @"game15", @"game16", @"game17", nil];
        /*
         */
    } else {
        //populate data from post result for array list in table view
        //may need to change when able to get proper response from API
        _gameListData = [NSMutableArray arrayWithObjects:[results valueForKey:@"name"], nil];
    }
}

- (void)buildView{
    //items used to build navigation bar of view
    int toolBarHeight = 60;
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, toolBarHeight)];
    UINavigationItem *navItem = [UINavigationItem alloc];
    navItem.title = @"GAMES";
    navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeGame)];
    navItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:(255/255.0) green:(198/255.0) blue:(27/255.0) alpha:1.0];
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:(255/255.0) green:(198/255.0) blue:(27/255.0) alpha:1.0]}];
    navigationBar.barTintColor = [UIColor darkGrayColor];
    navigationBar.translucent = NO;
    [navigationBar pushNavigationItem:navItem animated:false];
    [self.view addSubview:navigationBar];
    //items used to build the table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, toolBarHeight,self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:self.tableView];
}

- (void) composeGame {
    UIAlertView *getChatName = [[UIAlertView alloc] initWithTitle:@"TO CHALLENGE"
                                                          message:@"Provide Name For Challenge"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"OK"
                                , nil];
    //prompts keyboard response
    getChatName.alertViewStyle = UIAlertViewStylePlainTextInput;
    //sets appearance of keyboard to dark
    UITextField* keyboardStyle = [getChatName textFieldAtIndex:0];
    keyboardStyle.keyboardAppearance = UIKeyboardAppearanceDark;
    //display alert window
    [getChatName show];
}

//used to wait for user input for chat name
-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex: (NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"TO CHALLENGE"])
    {
        //check to see if user has actually entered anything, if not bring the alert window back up
        if ([[alertView textFieldAtIndex:0].text length]==0)
        {
            if (buttonIndex==1)
            {
            [self composeGame];
            }
        } else {
            //check of the "OK" button was selected
        if(buttonIndex==1)
        {
            //create dictionary to use for post
            NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] init];
            [jsonDictionary setObject:[NSString stringWithFormat:@"%@",[_userDict valueForKey:@"user_token"]] forKey:@"user_token"];
            [jsonDictionary setObject:[alertView textFieldAtIndex:0].text forKey:@"name"];
            [jsonDictionary setObject:[_userDict valueForKey:@"picture"] forKey:@"picture"];
            NSDictionary *results = [_oraGetGameList postToOra:@"/api/chats/create.json" :jsonDictionary];
            if (results && [[results valueForKey:@"error"]isEqualToString:@"YES"]) {
                //build of alert window
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                                message:@"UNABLE TO CREATE GAME" delegate:self cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                //display alert window
                [alert show];
                //for testing purposes currently still segue to challenge screen
                _chatIDForGame = @"1";
                [self performSegueWithIdentifier:@"newGameSegue" sender:self];
            } else {
                _chatIDForGame = [results valueForKey:@"id"];
                [self performSegueWithIdentifier:@"newGameSegue" sender:self];
            }
            
        }
    }
}
}

//determine how many cells required
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_gameListData count];
}

//build cells of UITable View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *gameListIdentifier = @"gameListItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:gameListIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:gameListIdentifier];
    }
    cell.textLabel.text = [_gameListData objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor darkGrayColor];
    cell.textLabel.textColor = [UIColor colorWithRed:(255/255.0) green:(198/255.0) blue:(27/255.0) alpha:1.0];
    return cell;
}

//perform when cell selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self getGameInfo]){
        [self performSegueWithIdentifier:@"openGameSegue" sender:self];
    }
}

- (NSString *) getGameInfo
{
    //create dictionary to use for post to chat messages index.
    //unable to fully determine how to get messages of only one chat
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:[NSString stringWithFormat:@"%@",[_userDict valueForKey:@"user_token"]] forKey:@"user_token"];
    [jsonDictionary setObject:@"1" forKey:@"page"];
    [jsonDictionary setObject:@"30" forKey:@"limit"];
    NSDictionary *results = [_oraGetGameList postToOra:@"/api/chatmessages.json" :jsonDictionary];
    if (results && [[results valueForKey:@"error"]isEqualToString:@"YES"]) {
        //set message for game to nil and display error
        NSLog(@"%@", @"Unable to open game.");
        _messageForGame = nil;
        //build of alert window
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"UNABLE TO OPEN GAME" delegate:self cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        //display alert window
        [alert show];
        //below lines are for testing only as I am unable to setup users in the API
        //if using to test comment out 2 alert view lines above
        _messageForGame = @"110--120--5";
        _messageWordForGame = @"!!TESTING";
        _chatIDForGame = [results valueForKey:@"chat_id"];
    } else {
        //
        /*logic needed to get latest messages for chat id from selected cell.
         Format of message should be the userScore--competitorScore--roundNumber
         matchViewController will post a message starting with "!!" that can be used to determine if a user has already guessed or attempted to guess a word*/
        //
        _chatIDForGame = [results valueForKey:@"chat_id"];
        _messageForGame = @"110--120--5";
        _messageWordForGame = @"!!TESTING";
    }
    //verify value received contains "--" to avoid errors
    if (![_messageForGame componentsSeparatedByString:@"--"].count > 1){
        _messageForGame = nil;
    }
    return _messageForGame;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //check to see if segue is openGameSegue
    if ([segue.identifier isEqualToString:@"openGameSegue"]){
        //set variables in destination view controller
        MatchViewController *controller = (MatchViewController *)segue.destinationViewController;
        controller.gameMessageData = _messageForGame;
        controller.gameMessageWordData = _messageWordForGame;
        controller.chatID = _chatIDForGame;
        controller.userDict = _userDict;
    } else if ([segue.identifier isEqualToString:@"newGameSegue"]){
        //set variables in destination view controller
        challengeViewController *controller = (challengeViewController *)segue.destinationViewController;
        controller.chatID = _chatIDForGame;
        controller.userDict = _userDict;
    }
}
@end
