// SwiftUI Custom Navigation (Flutter-like Navigator 2.0 Style)
import SwiftUI
import Combine

// MARK: - 1) Define all pages in a type-safe enum
enum AppPage: Identifiable {
    case home
    case login
    case profile(userID: String)
    case detail(itemID: Int, itemName: String)

    var id: String {
        switch self {
        case .home: return "home"
        case .login: return "login"
        case .profile(let id): return "profile-\(id)"
        case .detail(let id, _): return "detail-\(id)"
        }
    }

    @ViewBuilder
    func buildView() -> some View {
        switch self {
        case .home:
            HomeView()
        case .login:
            LoginView()
        case .profile(let userID):
            ProfileView(userID: userID)
        case .detail(let itemID, let itemName):
            DetailView(itemID: itemID, name: itemName)
        }
    }
}

// MARK: - 2) Router to manage navigation stack programmatically
class Router: ObservableObject {
    @Published private(set) var pages: [AppPage] = [.home]
    static let instance = Router()
    private init() {}

    var pagesCount: Int { pages.count }
    var canPop: Bool { pages.count > 1 }

    func push(_ page: AppPage) {
        withAnimation {
            pages.append(page)
        }
    }

    func pop() {
        guard canPop else { return }
        withAnimation {
            pages.removeLast()
        }
    }

    func replace(with page: AppPage) {
        pop()
        push(page)
    }

    func replaceAll(with page: AppPage) {
        withAnimation {
            pages = [page]
        }
    }

    private var resultSubject: PassthroughSubject<Bool, Never>?

    @MainActor
    func waitForResult(_ page: AppPage) async -> Bool {
        push(page)
        resultSubject = PassthroughSubject<Bool, Never>()
        var cancellables = Set<AnyCancellable>()
        return await Future<Bool, Never> { promise in
            self.resultSubject?
                .sink { value in promise(.success(value)) }
                .store(in: &cancellables)
        }
        .value
    }

    func returnWith(_ value: Bool) {
        pop()
        resultSubject?.send(value)
        resultSubject = nil
    }
}

// MARK: - 3) Custom Navigation View rendering the page stack using ZStack
struct CustomNavigationView: View {
    @StateObject private var router = Router.instance

    var body: some View {
        ZStack {
            ForEach(router.pages, id: \ .id) { page in
                let isTop = page.id == router.pages.last?.id
                page.buildView()
                    .disabled(!isTop)
                    .opacity(isTop ? 1 : 0)
                    .animation(.default, value: router.pages.map(\ .id))
            }
        }
    }
}

// MARK: - 4) Example Views to demonstrate navigation
struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Home Screen")
                .font(.largeTitle)
            Button("Go to Login") {
                Router.instance.push(.login)
            }
            Button("Go to Profile (ID=123)") {
                Router.instance.push(.profile(userID: "123"))
            }
        }
        .padding()
    }
}

struct LoginView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Login Screen")
                .font(.largeTitle)
            Button("Back") {
                Router.instance.pop()
            }
        }
        .padding()
    }
}

struct ProfileView: View {
    let userID: String
    var body: some View {
        VStack(spacing: 20) {
            Text("Profile for ID: \(userID)")
                .font(.title)
            Button("Detail View") {
                Router.instance.push(.detail(itemID: 42, itemName: "Swift Book"))
            }
            Button("Back") {
                Router.instance.pop()
            }
        }
        .padding()
    }
}

struct DetailView: View {
    let itemID: Int
    let name: String
    var body: some View {
        VStack(spacing: 20) {
            Text("Item ID: \(itemID)")
            Text("Name: \(name)")
            Button("Return true") {
                Router.instance.returnWith(true)
            }
            Button("Return false") {
                Router.instance.returnWith(false)
            }
            Button("Back") {
                Router.instance.pop()
            }
        }
        .padding()
    }
}

// MARK: - 5) App Entry Point
@main
struct RouterApp: App {
    var body: some Scene {
        WindowGroup {
            CustomNavigationView()
        }
    }
}
