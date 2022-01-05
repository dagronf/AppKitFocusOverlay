//
//  ViewController.m
//  AppKitFocusOverlay Objc Demo
//
//  Created by Darren Ford on 5/1/2022.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak) IBOutlet NSSearchField *searchField;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view.
}

- (void)viewWillAppear {
	[[[self view] window] setInitialFirstResponder:[self searchField]];
	//[[[self view] window] recalculateKeyViewLoop];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}


@end
