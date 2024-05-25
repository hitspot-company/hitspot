# Hitspot Development Naming Conventions

## General Guidelines
1. **Consistency:** Follow these conventions consistently throughout the codebase.
2. **Clarity:** Choose names that clearly convey the purpose of the class, method, or variable.
3. **Prefixes:** Use the `HS` prefix for all blocs, util classes, and widgets to maintain a clear namespace.

## Naming Conventions

### Blocs and Cubits
- **Prefix:** `HS`
- **Naming:** Use PascalCase for class names.
- **Examples:**
  - `HSLoginBloc`
  - `HSSpotCubit`
  - `HSUserProfileBloc`

### Util Classes
- **Prefix:** `HS`
- **Naming:** Use PascalCase for class names.
- **Examples:**
  - `HSNetworkUtils`
  - `HSDateFormatter`

### Widgets
- **Prefix:** `HS`
- **Naming:** Use PascalCase for class names.
- **Examples:**
  - `HSLoginButton`
  - `HSSpotCard`
  - `HSUserProfileAvatar`

### Pages
- **Naming:** Use classic names with PascalCase.
- **Examples:**
  - `LoginPage`
  - `SpotPage`
  - `UserProfilePage`

## Feature Directory Structure
Each feature should be organized in a consistent structure as follows:

```
<feature_directory>
    - view
        - <feature>_provider.dart
        - <feature>_page.dart
    - bloc / cubit
        - hs_<feature>_bloc.dart / hs_<feature>_cubit.dart
        - ...
```

In case a feature does not need blocs or cubits the `view` directory is still required with the exception of `<feature>_provider` file. The bloc / cubit directory should then be ommited.
### Example Structure

#### Login Feature
```
login
    - view
        - login_page_provider.dart
        - login_page_view.dart
    - cubit
        - hs_login_cubit.dart
        - hs_login_state.dart
```

#### User Profile Feature
```
user_profile
    - view
        - user_profile_provider.dart
        - user_profile_page.dart
    - bloc
        - hs_user_profile_bloc.dart
        - hs_user_profile_state.dart
        - hs_user_profile_event.dart
```

## Detailed Examples

### Blocs and Cubits

#### `HSLoginBloc` (bloc/hs_login_bloc.dart)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';

class HSLoginBloc extends Bloc<LoginEvent, LoginState> {
  // Bloc implementation
}
```

#### `HSSpotCubit` (cubit/hs_spot_cubit.dart)
```dart
import 'package:bloc/bloc.dart';

class HSSpotCubit extends Cubit<SpotState> {
  // Cubit implementation
}
```

### Util Classes

#### `HSNetworkUtils` (utils/navigation/hs_navigation_service.dart)
```dart
class HSNavigationService {
  // Utility methods for navigation and deep linking
}
```

#### `HSDateFormatter` (utils/theme/hs_theme.dart)
```dart
class HSTheme {
  // Utility methods for theme management
}
```

### Widgets

#### `HSLoginButton` (widgets/hs_login_button.dart)
```dart
import 'package:flutter/material.dart';

class HSLoginButton extends StatelessWidget {
  // Widget implementation
}
```

#### `HSSpotCard` (widgets/hs_spot_card.dart)
```dart
import 'package:flutter/material.dart';

class HSSpotCard extends StatelessWidget {
  // Widget implementation
}
```

### Pages

#### `LoginPage` (login/view/login_page_view.dart)
```dart
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  // Page implementation
}
```

#### `SpotPage` (spot/view/spot_page_view.dart)
```dart
import 'package:flutter/material.dart';

class SpotPage extends StatelessWidget {
  // Page implementation
}
```

#### `UserProfilePage` (user_profile/view/user_profile_page_view.dart)
```dart
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  // Page implementation
}
```

---

This document provides a clear guideline on naming conventions and the directory structure for features in your project. By following these conventions, you ensure consistency and clarity across the codebase, making it easier for developers to navigate and maintain the project.