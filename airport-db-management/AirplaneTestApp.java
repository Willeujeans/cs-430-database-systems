import javax.swing.*;
import java.awt.*;
import java.sql.*;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public class AirplaneTestApp {
    // START-STUDENT-CODE
    // Set the database connection URL and credentials
    private static final String DB_URL = "jdbc:postgresql://faure.cs.colostate.edu:5432/willschm?currentSchema=airport";
    private static final String DB_USER = "willschm";
    private static final String DB_PASSWORD = "831553213";
    // END-STUDENT-CODE

    private JFrame loginFrame, testEventFrame;
    private JTextField usernameField, scoreField;
    private JTextField hoursField, minutesField, secondsField;
    private JPasswordField passwordField;
    private JComboBox<String> airplaneDropdown, testDropdown;
    private int loggedInTechnicianId;

    public static void main(String[] args) {
        SwingUtilities.invokeLater(AirplaneTestApp::new);
    }

    public AirplaneTestApp() {
        createLoginFrame();
    }

    /*--------------------------- UI Construction Helpers ------------------- */
    private JLabel createLabel(String text, int fontSize) {
        JLabel label = new JLabel(text);
        label.setFont(label.getFont().deriveFont((float) fontSize));
        return label;
    }

    private JTextField createTextField(int columns, int fontSize) {
        JTextField field = new JTextField(columns);
        field.setFont(field.getFont().deriveFont((float) fontSize));
        return field;
    }

    private JPasswordField createPasswordField(int fontSize) {
        JPasswordField field = new JPasswordField();
        field.setFont(field.getFont().deriveFont((float) fontSize));
        return field;
    }

    private JButton createButton(String text, int fontSize) {
        JButton button = new JButton(text);
        button.setFont(button.getFont().deriveFont((float) fontSize));
        return button;
    }

    /*-------------------------- Login Screen --------------------------------*/
    private void createLoginFrame() {
        loginFrame = new JFrame("Technician Login");
        loginFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        loginFrame.setResizable(false);

        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        // Username
        panel.add(createLabel("Username:", 18));
        usernameField = createTextField(15, 18);
        panel.add(usernameField);
        panel.add(Box.createVerticalStrut(10));

        // Password
        panel.add(createLabel("Password:", 18));
        passwordField = createPasswordField(18);
        panel.add(passwordField);
        panel.add(Box.createVerticalStrut(10));

        // Login Button
        JButton loginButton = createButton("Login", 18);
        loginButton.addActionListener(e -> authenticateTechnician());
        panel.add(loginButton);

        loginFrame.add(panel);
        loginFrame.pack();
        loginFrame.setLocationRelativeTo(null);
        loginFrame.setVisible(true);
    }

    private void authenticateTechnician() {
        String username = usernameField.getText().trim();
        String password = new String(passwordField.getPassword()).trim();
        String hashedPassword = hashPassword(password);

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            String sql = "SELECT e.password FROM airport.employee e " +
                    "JOIN airport.technician t ON e.ssn = t.ssn WHERE e.ssn = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();

            if (rs.next() && hashedPassword.equals(rs.getString("password"))) {
                loggedInTechnicianId = Integer.parseInt(username);
                loginFrame.dispose();
                showTestEntryScreen();
            } else {
                JOptionPane.showMessageDialog(loginFrame,
                        "Invalid credentials", "Error", JOptionPane.ERROR_MESSAGE);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(loginFrame,
                    "Error during login", "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    /*-------------------------- Test Entry Screen ---------------------------*/
    private void showTestEntryScreen() {
        testEventFrame = new JFrame("Record Airworthiness Test");
        testEventFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JPanel mainPanel = new JPanel();
        mainPanel.setLayout(new BoxLayout(mainPanel, BoxLayout.Y_AXIS));
        mainPanel.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));

        // Row 1: Airplane
        JPanel row1 = new JPanel(new FlowLayout(FlowLayout.LEFT, 5, 0));
        row1.add(createLabel("Select Airplane:", 18));
        airplaneDropdown = new JComboBox<>();
        airplaneDropdown.setFont(airplaneDropdown.getFont().deriveFont(18f));

        // START-STUDENT-CODE
        // Write the query used to populate airplaneDropdown with the
        // registration numbers from the "airplane" table.
        populateDropdown(airplaneDropdown, "SELECT registration FROM airport.airplane");
        // END-STUDENT-CODE

        row1.add(airplaneDropdown);
        mainPanel.add(row1);

        // Row 2: Test
        JPanel row2 = new JPanel(new FlowLayout(FlowLayout.LEFT, 5, 0));
        row2.add(createLabel("Select Test:", 18));
        testDropdown = new JComboBox<>();
        testDropdown.setFont(testDropdown.getFont().deriveFont(18f));

        // START-STUDENT-CODE
        // Write the query to populate testDropdown with the test_number from
        // "faa_test" table.
        populateDropdown(testDropdown, "SELECT test_number FROM airport.faa_test");
        // END-STUDENT-CODE

        row2.add(testDropdown);
        mainPanel.add(row2);

        // Row 3: Duration
        JPanel row3 = new JPanel(new FlowLayout(FlowLayout.LEFT, 5, 0));
        row3.add(createLabel("Duration:", 18));
        row3.add(createLabel("H:", 18));
        hoursField = createTextField(3, 18);
        row3.add(hoursField);
        row3.add(createLabel("M:", 18));
        minutesField = createTextField(3, 18);
        row3.add(minutesField);
        row3.add(createLabel("S:", 18));
        secondsField = createTextField(3, 18);
        row3.add(secondsField);
        mainPanel.add(row3);

        // Row 4: Score
        JPanel row4 = new JPanel(new FlowLayout(FlowLayout.LEFT, 5, 0));
        row4.add(createLabel("Score:", 18));
        scoreField = createTextField(5, 18);
        row4.add(scoreField);
        mainPanel.add(row4);

        // Row 5: Buttons
        JPanel row5 = new JPanel(new FlowLayout(FlowLayout.CENTER, 5, 0));
        JButton submitButton = createButton("Submit Test", 18);
        submitButton.addActionListener(e -> submitTestRecord());
        JButton logoutButton = createButton("Logout", 18);
        logoutButton.addActionListener(e -> logout());
        row5.add(submitButton);
        row5.add(logoutButton);
        mainPanel.add(row5);

        testEventFrame.add(mainPanel);
        testEventFrame.pack();
        testEventFrame.setLocationRelativeTo(null);
        testEventFrame.setVisible(true);
    }

    private void populateDropdown(JComboBox<String> dropdown, String query) {
        dropdown.removeAllItems();
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(query)) {
            while (rs.next()) {
                dropdown.addItem(rs.getString(1));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

    private void submitTestRecord() {
        String airplane = (String) airplaneDropdown.getSelectedItem();
        String test = (String) testDropdown.getSelectedItem();
        String h = hoursField.getText().trim();
        String m = minutesField.getText().trim();
        String s = secondsField.getText().trim();
        String scoreTxt = scoreField.getText().trim();

        if (airplane == null || test == null || h.isEmpty() || m.isEmpty() ||
                s.isEmpty() || scoreTxt.isEmpty()) {
            JOptionPane.showMessageDialog(testEventFrame,
                    "All fields must be filled!",
                    "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try {
            int testNum = Integer.parseInt(test);
            int hours = Integer.parseInt(h);
            int mins = Integer.parseInt(m);
            int secs = Integer.parseInt(s);
            int score = Integer.parseInt(scoreTxt);

            // START-STUDENT-CODE
            // Build the logic to insert a new test event into the "test_event"
            // table.
            String sql = "INSERT INTO airport.test_event (test_number, technician_id, airplane_registration, hours, minutes, seconds, score) VALUES (?, ?, ?, ?, ?, ?, ?)";
            // END-STUDENT-CODE

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                    PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, testNum);
                stmt.setInt(2, loggedInTechnicianId);
                stmt.setString(3, airplane);
                stmt.setInt(4, hours);
                stmt.setInt(5, mins);
                stmt.setInt(6, secs);
                stmt.setInt(7, score);
                stmt.executeUpdate();
            }

            JOptionPane.showMessageDialog(testEventFrame, "Test recorded successfully!");
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(testEventFrame,
                    "Hours, minutes, seconds, test #, and score must be numeric!",
                    "Error", JOptionPane.ERROR_MESSAGE);
        } catch (SQLException e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(testEventFrame,
                    "Database error occurred!", "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void logout() {
        testEventFrame.dispose();
        createLoginFrame();
    }

    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                hexString.append(String.format("%02x", b));
            }
            return hexString.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
