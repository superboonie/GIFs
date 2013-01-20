//
//  ORSimpleSourceListView.m
//  GIFs
//
//  Created by orta therox on 20/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import "ORSimpleSourceListView.h"

CGFloat ORCellHeight = 28;
CGFloat ORCellLeftPadding = 12;

CGFloat ORCellTitleTopPadding = 8;

CGFloat ORCellItemLeftPadding = 40;
CGFloat ORCellItemTopPadding = 6;

CGFloat ORCellImageDimensions = 16;

@implementation NSIndexPath(SourceListExtension)
+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section {
    NSUInteger indexArr[] = { row, section };
    return [NSIndexPath indexPathWithIndexes:indexArr length:2];
}
- (NSUInteger)row { return [self indexAtPosition:0]; }
- (NSUInteger)section { return [self indexAtPosition:1]; }
@end

@implementation ORSourceListItem

@end

@implementation ORSimpleSourceListView {
    // Items stores both titles and items
    NSArray *_items;
    NSUInteger _currentSelectionIndex;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __setup];
    }
    return self;
}

- (void)__setup {
    self.delegate = self;
    self.dataSource = self;
    self.focusRingType = NSFocusRingTypeNone;
    self.headerView = nil;
    self.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    self.intercellSpacing = CGSizeMake(0, 0);
    self.backgroundColor = [NSColor colorWithCalibratedRed:0.2039 green:0.1922 blue:0.2275 alpha:1.0000];

    _currentSelectionIndex = NSNotFound;
}

- (void)awakeFromNib {
    [self reloadData];
}

- (void)reloadData {    
    if(_sourceListDataSource){
        NSUInteger numberOfSections = [_sourceListDataSource numberOfSectionsInSourceList:self];
        if(!numberOfSections) return;

        NSMutableArray *mutableItems = [NSMutableArray array];
        for (int i = 0; i < numberOfSections; i++) {
            [mutableItems addObject:[_sourceListDataSource sourceList:self titleOfHeaderForSection:i]];
            NSUInteger numberOfRows = [_sourceListDataSource sourceList:self numberOfRowsInSection:i];

            for (int j = 0; j < numberOfRows; j++) {
                NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [mutableItems addObject:[_sourceListDataSource sourceList:self sourceListItemForIndexPath:currentIndexPath]];
            }
        }
        _items = [NSArray arrayWithArray:mutableItems];
    }
    
    [super reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _items.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return ORCellHeight;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {    
    id item =_items[row];
    NSTableCellView *result;
    if ([item isMemberOfClass:[ORSourceListItem class]]){
        ORSourceListItem *sourceListItem = (ORSourceListItem *)item;
        result = [[ORSourceListItemView alloc] initWithSourceListItem:sourceListItem];

    } else {
        NSString *headerString = (NSString *)item;
        result = [[ORSourceListHeaderView alloc] initWithTitle:headerString];
    }
    return result;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    id item =_items[row];
    return [item isKindOfClass:[ORSourceListItem class]];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    NSInteger index = [self selectedRow];
    if (index == _currentSelectionIndex || index == -1) {
        return;
    }

    id item = _items[index];
    if ([item isMemberOfClass:[ORSourceListItem class]]) {
        if (_currentSelectionIndex != NSNotFound) {
            ORSourceListItemView *oldCell = [self viewAtColumn:0 row:_currentSelectionIndex makeIfNecessary:NO];
            if (oldCell && [oldCell isKindOfClass:[ORSourceListItemView class]]) {
                oldCell.selected = NO;
            }
        }

        ORSourceListItemView *cell = [self viewAtColumn:0 row:index makeIfNecessary:NO];
        if (cell) {
            cell.selected = YES;
        }

        _currentSelectionIndex = index;
        NSIndexPath *path = [self rowToIndexPath:index];
        [_sourceListDelegate sourceList:self selectionDidChangeToIndexPath:path];
    }
}

- (NSIndexPath *)rowToIndexPath:(NSUInteger)row {
    NSInteger indexRow = -1;
    NSInteger indexSection = -1;
    for (int i = 0; i < (row + 1); i++) {
        if ([_items[i] isKindOfClass:[ORSourceListItem class]]) {
            indexRow++;
        } else {
            indexSection++;
            indexRow = -1;
        }
    }
    return [NSIndexPath indexPathForRow:indexRow inSection:indexSection];
}

+ (NSTextField *)textFieldForItems {
    NSTextField *titleLabel = [[NSTextField alloc] init];
    [titleLabel setBezeled:NO];
    [titleLabel setDrawsBackground:NO];
    [titleLabel setEditable:NO];
    [titleLabel setSelectable:NO];
    [[titleLabel cell] setBackgroundStyle:NSBackgroundStyleRaised];
    titleLabel.font = [NSFont fontWithName:@"Ariel" size:12];
    titleLabel.textColor = [NSColor colorWithCalibratedRed:0.550 green:0.522 blue:0.598 alpha:1.000];
    return titleLabel;
}

+ (NSTextField *)textFieldForHeaders {
    NSTextField *headerTextField = [self textFieldForItems];
    headerTextField.font = [NSFont fontWithName:@"Ariel" size:10];
    return headerTextField;
}


@end

@implementation ORSourceListHeaderView

- (id)initWithTitle:(NSString *)title {
    self = [super init];
    if(!self)return nil;

    NSTextField *headerTextField = [ORSimpleSourceListView textFieldForHeaders];
    self.textField = headerTextField;
    [self addSubview:headerTextField];

    self.textField.stringValue = [title uppercaseString];    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // The lighter grey
    [[NSColor colorWithCalibratedRed:0.2314 green:0.2196 blue:0.2549 alpha:1.0000] set];
	NSRectFill(dirtyRect);
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    self.textField.frame = CGRectMake(ORCellLeftPadding, -ORCellTitleTopPadding, CGRectGetWidth(frameRect) - ORCellLeftPadding, ORCellHeight);
}

@end

@implementation ORSourceListItemView {
    NSString *_thumbnail;
    NSString *_selectedThumbnail;
}

- (id)initWithSourceListItem:(ORSourceListItem *)item {
    self = [super init];
    if(!self)return nil;

    _thumbnail = item.thumbnail;
    _selectedThumbnail = item.selectedThumbnail;

    NSTextField *titleTextField = [ORSimpleSourceListView textFieldForItems];
    self.textField = titleTextField;
    [self addSubview:titleTextField];

    NSImageView *itemImage = [[NSImageView alloc] init];
    self.imageView = itemImage;
    [self addSubview:itemImage];

    self.textField.stringValue = item.title;
    self.imageView.image = [NSImage imageNamed:_thumbnail];
    return self;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    self.textField.frame = CGRectMake(ORCellItemLeftPadding, -ORCellItemTopPadding, CGRectGetWidth(frameRect) - ORCellItemLeftPadding, ORCellHeight);
    self.imageView.frame = CGRectMake(ORCellLeftPadding, CGRectGetHeight(frameRect)/2 - ORCellImageDimensions/2, ORCellImageDimensions, ORCellImageDimensions);
}

- (void)drawRect:(NSRect)dirtyRect {
    if (_selected) {
        [[NSColor colorWithCalibratedRed:0.206 green:0.449 blue:0.940 alpha:1.000] set];
        self.textField.textColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1.000 alpha:1.000];
        self.imageView.image = [NSImage imageNamed:_selectedThumbnail];
    } else {
        self.imageView.image = [NSImage imageNamed:_thumbnail];
        self.textField.textColor = [NSColor colorWithCalibratedRed:0.550 green:0.522 blue:0.598 alpha:1.000];
        [[NSColor colorWithCalibratedRed:0.150 green:0.140 blue:0.169 alpha:1.000] set];

    }
    NSRectFill(dirtyRect);
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (selected) {
        self.textField.textColor = [NSColor colorWithCalibratedRed:0.723 green:0.810 blue:0.955 alpha:1.000];
    } else {
        self.textField.textColor = [NSColor colorWithCalibratedRed:0.2314 green:0.2196 blue:0.2549 alpha:1.0000];
    }
    [self setNeedsDisplay:YES];
}

@end