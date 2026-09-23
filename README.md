# SampleSectionedQuery

This project is a sample App for the swiftdata-sectionedquery package found at: https://github.com/Whiffer/swiftdata-sectionedquery

\*\* NOTE for macOS 27.0 and iOS 27.0:
Even though Apple has added a native @Query(sectionBy:) property wrapper to SwiftData in the 27.0 versions of iOS and macOS, in order to use it seamlessly, you must duplicate the property you want to group by on the child model, and therefore denormalize your database.  This is because you cannot group the sectioned query directly by a relationship property (e.g., sectionBy: \.category.name). The underlying database engine requires the sectionBy keypath to target a persisted, primitive string/value property belonging directly to the root model.

Until Apple removes this restriction, the swiftdata-sectionedquery package remains a viable alternative to solve this issue.

## Verion History
2026-09-22 Reorganized the Test Data and Toolbar Buttons to give a clearer picture of how to setup the @SectionedQuery property wrapper and how to make dynamic changes to it

2025-02-01 Added demo for making changes to the sectionIdentifier

2023-08-26 Changes required to compile and run with Xcode Beta 7.

## Usage Notes

1. Build and run this project for either macOS 14.0 (or later) or iOS 17.0 (or later).
2. After the App starts, tap the '(re)Load' button to initialize the SwiftData Model Context. Tapping '(re)Load' again will reload the Model Context to its original state, but not change the Item or Attribute sort settings.
3. Tapping the 'Toggle Section by' button will alternate between grouping Attributes by their related Item and by their own name property.
4. Tapping the 'Toggle Item Sort' button will toggle the Item's SortDescriptor between .forward and .reverse
5. Tapping the 'Toggle Attribute Sort' button will toggle the Attribute's SortDescriptor between .forward and .reverse
6. Tapping the 'Swap first two Item names' button will swap the name properties of the first two ordered Items.  The expected result is that the first and second sections will change places. Tapping 'Swap' again should swap the first and second sections back to their original positions. When sorting in reverse, the second and third sestions will be swapped.
7. Entering text in the Searchbar will filter the Attribute's and show only those Attribute's with name's that contain the searchTerm as a substring
