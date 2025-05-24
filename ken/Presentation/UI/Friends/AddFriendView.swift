//
//  AddFriendView.swift
//  ken
//
//  Created by Lakshay Gupta on 04/05/25.
//
import SwiftUI
//
//  AddFriendView.swift
//  ken
//
//  Created by Lakshay Gupta on 04/05/25.
//
import SwiftUI

struct AddFriendView: View {
    // MARK: - Properties
    @ObservedObject var leetCodeVM: LeetCodeViewModel
    @ObservedObject var savedUsersVM: SavedUsersViewModel
    @Binding var isPresented: Bool
    @Binding var username: String
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isSuccessful = false
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isTextFieldFocused: Bool
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                backgroundView
                
                ScrollView {
                    VStack(spacing: 32) {
                
                        UsernameInputSection(
                            username: $username,
                            errorMessage: errorMessage,
                            isTextFieldFocused: $isTextFieldFocused,
                            onSubmit: addFriend
                        )
                        
                        AddFriendButton(
                            isLoading: isLoading,
                            isDisabled: username.isEmpty || isLoading,
                            action: addFriend
                        )
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                
                // Success overlay
                if isSuccessful {
                    SuccessOverlay()
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        AppTheme.shared.backgroundColor(in: colorScheme)
            .ignoresSafeArea()
    }
    
    // MARK: - Add Friend Method
    private func addFriend() {
        guard !username.isEmpty else { return }
        
        isLoading = true
        withAnimation {
            errorMessage = nil
        }
        
        // Close keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        Task {
            let success = await leetCodeVM.fetchData(for: username)
            
            await MainActor.run {
                if success {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isSuccessful = true
                    }
                    savedUsersVM.addUsername(username)
                    username = ""
                    
                    // Delay dismissal to show success animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isPresented = false
                        isSuccessful = false
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        errorMessage = "Could not find that LeetCode username"
                    }
                }
                isLoading = false
            }
        }
    }

}


// MARK: - Username Input Section
private struct UsernameInputSection: View {
    @Binding var username: String
    var errorMessage: String?
    var isTextFieldFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text("LeetCode username")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            // Input field
            HStack(spacing: 12) {
                Image(systemName: "person")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                TextField("e.g. leetcoder123", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused(isTextFieldFocused)
                    .submitLabel(.go)
                    .onSubmit(onSubmit)
                    .font(.body)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        errorMessage != nil ? Color.red.opacity(0.6) : Color.gray.opacity(0.3),
                        lineWidth: errorMessage != nil ? 1.5 : 1
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.shared.cardBackgroundColor(in: colorScheme))
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
            
            // Error message
            if let errorMessage = errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.leading, 4)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Add Friend Button
private struct AddFriendButton: View {
    var isLoading: Bool
    var isDisabled: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Text("Add Friend")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(isDisabled ? 0.5 : 1.0)
            )
            .cornerRadius(15)
            .shadow(color: isDisabled ? Color.clear : Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .disabled(isDisabled)
        .padding(.top, 10)
    }
}

// MARK: - Success Overlay
private struct SuccessOverlay: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .opacity(opacity)
            
            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 90, height: 90)
                        .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                
                Text("Friend Added!")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.2)) {
                opacity = 1.0
            }
        }
    }
}

// MARK: - Preview
struct AddFriendView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendView(
            leetCodeVM: LeetCodeViewModel(),
            savedUsersVM: SavedUsersViewModel(),
            isPresented: .constant(true),
            username: .constant("")
        )
        .preferredColorScheme(.light)
        
        AddFriendView(
            leetCodeVM: LeetCodeViewModel(),
            savedUsersVM: SavedUsersViewModel(),
            isPresented: .constant(true),
            username: .constant("")
        )
        .preferredColorScheme(.dark)
    }
}
