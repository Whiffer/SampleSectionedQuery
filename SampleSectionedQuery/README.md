# SampleSectionedQuery

This project is a sample App for the swiftdata-sectionedquery package found at: https://github.com/Whiffer/swiftdata-sectionedquery

## Usage Notes

1. Build and run this project for either macOS 14 or iOS 17 Beta 2 or later.

2. After the App starts, tap the 'Load' button to initialize the SwiftData Model Context. Tapping 'Load' again will restore the Model Context to its original state, but not change the Item sorting or Attribute filtering.

3. Tapping the 'Swap' button will swap the order properties of the first two Items.  The expected result is that the first and second sections will change places. Tapping 'Swap' again should swap the first and sections back to their original positions.

4. Tapping the 'Item Sort' button will toggle the Item's SortDescriptor between .forward and .reverse

5. Tapping the 'Attribute Filter' button will alternate between showing all Attributes and only the first Attribute of each Item (i.e. Section).

