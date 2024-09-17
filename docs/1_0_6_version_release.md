# Version Release: 1.0.6 

## 1. Permissions

### Photo gallery

*bug:* Once the user declines permission to access the photo gallery the application never asks again and there is no hint about how to overcome it.


*fix:* Show the user a screen prompting him to access the permissions and inform about the current state


### Location
*issue:* If the user declines access to the current location the app is set to a constant LatLng.

*fix:* Try to estimate the location with *some* accuracy and show start there.


## 2. Flow management

### Location
*bug:* the location on spot creation / update has to be chosen a few times (?)

*bug:* when updating spot start from the last selected location not from current user location

## 3. TODO features

### Enhanced Refresh
The **Home Page** refresh should work in an exciting way - showing previously unseen spots each time, starting with the ones uploaded by friends / trending / nearby / fresh.

### Autozooming Map
The **Map Page** should auto-zoom itself to show the closest spots on *entered / button pressed*. 

**Idea:** fetch the closest 20 spots and zoom out to the furthest bounds (or any ohter way to include all spots)

### UI Fixes
Consider and implement UI fixes suggested by the beta testers.

- [ x ] Fix login by magic link

### Board Map Auto-Zoom
Implement the removed feature of zooming out to see all spots included in a board.

### Enhanced Boards
Implement the ability to mark spots as seen / not seen. Find a more indicative way of showing the order of spots in the board.

### Enhanced Saved
Add a searchbar to the saved spots / boards page.

### Followers / Following Page
Implement a page displaying the followers / followed users that can be accessed from the user profile page.

### Editing spot
- [ ] Implement editing images added to the spot

### Likers Page
Implement a page displaying the people that have liked a spot.

### Transaction
Implement transaction for creating a spot

## 4. Bugs

Implement bug fixes:
- [ ] Sometimes the address contains empty strings resulting in an order of empty commas
- [ ] Following / followers triggers not working on follow / unfollow
- [ ] The FCM Token is only registered on app entry -> should be on login
- [ ] When cancelling editing, user is moved to home page, when should be to his profile
- [ x ] When editing spot previously selected location should be displayed
- [ ] Something is wrong gathering interactions - only comments are tracked
- [ x ] Big letters in username should be allowed, but automatically changed to lowercase