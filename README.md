
GitHub Search-Dhruvil Patel


API Used: https://api.github.com/search/users

Video Demo: https://youtu.be/4MGv7MiEXcI

Data Fetched from API:
   1. User's avatar image
   2. GitHub userName
   3. Total number of followers and following
   4. User's location
   5. Public repos count
   6. User's GitHub Profile link
    
Things to know:
   1. User will be able to seach GitHub profiles dynamically(i.e update the list as user types.)
   2. User can then tap on that paticular user inorder to fetch more info about that user(i.e Detail Screen)
   3. User can also able to see followers of that profile
   4. User can also save  profile which can be viewed offiline(i.e Core Data framework is implemented for storing & fetching data)
   5. Compatible with iphone and ipad(i.e Universal interface support)
   6. Support's portrait and landscape orientation
   7. Pagination is implemented to fetch new data
   8. Design Pattern: MVC(Model View Controller)
   9. Tab Bars are used for navigating between search & saved data
   10. TableView is implmented for showing list of seached results
   11. Added  alert for : no networkConnectivity, failed API, empty data
   12. No use of third-party library

ViewController's Functionality:
   1. BaseViewController: Consists code which can be used in more than one view controller
   2. ViewController: It's the initial view controller consists of seach functionality & showing searched users
   3. SelectedUserViewController : It's the detail screen where in selected user's details are displayed
   4. UserDetailsViewController: Here selected user's followers list are displayed
   5. SavedViewController: Here saved users are displayed(i.e fetching from CoreData)





