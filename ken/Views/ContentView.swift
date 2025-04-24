import SwiftUI

struct ContentView: View {
    @StateObject private var leetCodeVM = LeetCodeViewModel()
    @StateObject private var savedUsersVM = SavedUsersViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        SearchBar(username: $leetCodeVM.currentUsername) {
                            leetCodeVM.fetchData(for: leetCodeVM.currentUsername)
                            savedUsersVM.addUsername(leetCodeVM.currentUsername)
                        }
                        .disabled(leetCodeVM.isLoading)
                        
                        if leetCodeVM.isLoading {
                            ProgressView()
                        } else {
                            if let stats = leetCodeVM.userStats[leetCodeVM.currentUsername] {
                                StatsView(stats: stats)
                            }
                            
                            if let calendar = leetCodeVM.userCalendars[leetCodeVM.currentUsername] {
                                CalendarView(calendar: calendar)
                            }
                        }
                        
                        if let error = leetCodeVM.error {
                            ErrorView(message: error.localizedDescription)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Search")
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            
            
            NavigationView {
                SavedUsersView(savedUsersVM: savedUsersVM, leetCodeVM: leetCodeVM)
                    .navigationTitle("Saved Users")
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Saved", systemImage: "star.fill")
            }
        }
        .tabViewStyle(.tabBarOnly)
    }
} 
