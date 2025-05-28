# SwiftUI-Nav-2.0

# Advanced Navigation in SwiftUI

I've found SwiftUI's native `NavigationView` to be quite limiting, especially when dealing with complex navigation flows in larger applications. Its inflexibility often leads to boilerplate code and makes managing navigation state a challenge.

---

## Why I Built This

Inspired by the robust and programmatic navigation capabilities of Flutter's Navigator 2.0, I set out to bring a similar level of control and flexibility to SwiftUI. My goal was to create a solution that allows for a fully programmatic, enum-based approach to page management.

---

## Features

This project introduces a **Router** class that liberates page transitions, offering features like:

* **Programmatic Navigation:** Control your navigation stack entirely through code.
* **Enum-Based Page Management:** Define your app's routes using enums for type-safety and clarity.
* **Push, Pop, and Replace:** Standard navigation operations are now straightforward and predictable.
* **Asynchronous Result Returns:** Pass data back from a popped view, enabling more dynamic user flows.

This approach significantly simplifies complex navigation scenarios and reduces the boilerplate often associated with SwiftUI's built-in navigation solutions.

---
