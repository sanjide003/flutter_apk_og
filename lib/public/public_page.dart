import 'package:flutter/material.dart';

class PublicPage extends StatefulWidget {
  const PublicPage({super.key});

  @override
  State<PublicPage> createState() => _PublicPageState();
}

class _PublicPageState extends State<PublicPage> {
  // മെനു തുറന്നിട്ടുണ്ടോ എന്ന് നോക്കാനുള്ള വേരിയബിൾ
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light background
      body: Stack(
        children: [
          // -----------------------------------------------------------
          // 1. പ്രധാന കണ്ടന്റ് (MAIN CONTENT)
          // -----------------------------------------------------------
          SingleChildScrollView(
            // ഹെഡറിന് താഴെ നിന്ന് തുടങ്ങാൻ പാഡിംഗ് നൽകുന്നു
            padding: const EdgeInsets.only(top: 110, bottom: 50),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(Icons.school_rounded, size: 60, color: Color(0xFF1565C0)),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Welcome to Fee edusy",
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: const Color(0xFF1565C0),
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "An DSD Institution Manager",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // ഡമ്മി കണ്ടന്റ് (സ്ക്രോളിംഗ് കാണിക്കാൻ വേണ്ടി)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              [Icons.calendar_today, Icons.photo_library, Icons.campaign, Icons.contact_support][index],
                              size: 30,
                              color: const Color(0xFF1565C0),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ["Academics", "Gallery", "Notices", "Contact"][index],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // കൂടുതൽ സ്ക്രോളിംഗ് സ്പേസ്
                const SizedBox(height: 500), 
              ],
            ),
          ),

          // -----------------------------------------------------------
          // 2. മെനു ബാക്ക്ഗ്രൗണ്ട് ഡിം (DIM BACKGROUND)
          // -----------------------------------------------------------
          if (_isMenuOpen)
            GestureDetector(
              onTap: () => setState(() => _isMenuOpen = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.black.withOpacity(0.4),
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // -----------------------------------------------------------
          // 3. ഫ്ലോട്ടിംഗ് മെനു (FLOATING MENU DROPDOWN)
          // -----------------------------------------------------------
          if (_isMenuOpen)
            Positioned(
              top: 90, // ഹെഡറിന് തൊട്ടുതാഴെ
              left: 20,
              right: 20,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // കണ്ടന്റ് ഉള്ളത്ര വലിപ്പം
                  children: [
                    const SizedBox(height: 10),
                    _buildMenuItem("Home", Icons.home_rounded),
                    _buildMenuItem("About Institution", Icons.info_outline_rounded),
                    _buildMenuItem("Academic Programs", Icons.menu_book_rounded),
                    _buildMenuItem("Gallery & Events", Icons.photo_library_outlined),
                    _buildMenuItem("Contact Us", Icons.phone_in_talk_rounded),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(),
                    ),
                    
                    // LOGIN OPTION (AT THE BOTTOM)
                    InkWell(
                      onTap: () {
                         setState(() => _isMenuOpen = false);
                         Navigator.pushNamed(context, '/login');
                      },
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.08),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 10),
                            Text(
                              "Login Portal",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // -----------------------------------------------------------
          // 4. ഫ്ലോട്ടിംഗ് ഹെഡർ (FLOATING HEADER)
          // -----------------------------------------------------------
          Positioned(
            top: 20, // മുകളിൽ നിന്നുള്ള അകലം
            left: 20, // ഇടത് വശത്തെ അകലം
            right: 20, // വലത് വശത്തെ അകലം
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(50), // റൗണ്ട് ഷേപ്പ്
              child: Container(
                height: 65,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Side: Logo & Name
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(Icons.school, size: 20, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Fee edusy",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    // Right Side: Hamburger Menu Icon
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          setState(() {
                            _isMenuOpen = !_isMenuOpen; // Toggle Menu
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isMenuOpen ? Colors.grey.shade100 : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                            size: 28,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // മെനു ഐറ്റം ഉണ്ടാക്കാനുള്ള വിഡ്ജറ്റ്
  Widget _buildMenuItem(String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: Colors.grey[600], size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      onTap: () {
        // മെനു ക്ലോസ് ചെയ്യുന്നു (നാവിഗേഷൻ പിന്നീട് ചേർക്കാം)
        setState(() => _isMenuOpen = false);
      },
    );
  }
}
