import os
import shutil
import glob

# Mapping of file source to destination
# If destination ends with /, it's a directory
moves = {
    # Home
    'lib/screen/home_screen.dart': 'lib/screen/home/',
    'lib/controller/home_screen_controller.dart': 'lib/screen/home/',
    
    # Prayer Time
    'lib/screen/prayer_time_detail_screen.dart': 'lib/screen/prayer_time/',
    'lib/controller/prayer_time_detail_controller.dart': 'lib/screen/prayer_time/',

    # Group
    'lib/controller/group/show_member_controller.dart': 'lib/screen/group/',
    'lib/controller/group/group_search_controller.dart': 'lib/screen/group/',
    'lib/controller/group/show_group_controller.dart': 'lib/screen/group/',
    'lib/controller/group/add_member_group_controller.dart': 'lib/screen/group/',
    'lib/controller/group/create_group_controller.dart': 'lib/screen/group/',
    'lib/controller/group/group_ngaji_screen_controller.dart': 'lib/screen/group/',
    
    # Prayer
    'lib/controller/prayer/list_prayer_controller.dart': 'lib/screen/prayer/',
    'lib/controller/prayer/create_prayer_controller.dart': 'lib/screen/prayer/',
    'lib/controller/prayer/show_prayer_controller.dart': 'lib/screen/prayer/',
    
    # Charity
    'lib/controller/charity/charity_show_controller.dart': 'lib/screen/charity/',
    'lib/controller/charity/charity_screen_controller.dart': 'lib/screen/charity/',
    'lib/controller/charity/charity_payment_controller.dart': 'lib/screen/charity/',
    'lib/controller/charity/charity_search_controller.dart': 'lib/screen/charity/',
    'lib/controller/charity/mosque_infaq_activity_detail_controller.dart': 'lib/screen/charity/',
    'lib/controller/charity/infaq_activity_controller.dart': 'lib/screen/charity/',
    'lib/controller/charity/infaq_activity_detail_controller.dart': 'lib/screen/charity/',
    'lib/controller/charity/charity_donatur_controller.dart': 'lib/screen/charity/',
    
    # Event
    'lib/controller/event_detail_controller.dart': 'lib/screen/event/',
    'lib/controller/event_registration_list_controller.dart': 'lib/screen/event/',
    'lib/controller/event/event_payment_controller.dart': 'lib/screen/event/',
    
    # Mosque
    'lib/controller/mosque_add_controller.dart': 'lib/screen/mosque/',
    'lib/controller/mosque_charity_controller.dart': 'lib/screen/mosque/',
    'lib/controller/mosque_charity_donatur_controller.dart': 'lib/screen/mosque/',
    'lib/controller/mosque_charity_payment_controller.dart': 'lib/screen/mosque/',
    'lib/controller/mosque_charity_show_controller.dart': 'lib/screen/mosque/',
    
    # Quran View
    'lib/controller/quran/tilawah_controller.dart': 'lib/screen/quran_view/',
    'lib/controller/quran/quran_list_screen_controller.dart': 'lib/screen/quran_view/',
    'lib/controller/quran/quran_page_screen_controller.dart': 'lib/screen/quran_view/',
    'lib/controller/quran/quran_list_detail_screen_controller.dart': 'lib/screen/quran_view/',
    'lib/controller/quran.dart': 'lib/screen/quran_view/',
    
    # Memorize Quran
    'lib/controller/memorization_controller.dart': 'lib/screen/memorize_quran/',
    'lib/controller/memorize_leaderboard_controller.dart': 'lib/screen/memorize_quran/',
    'lib/controller/level_detail_controller.dart': 'lib/screen/memorize_quran/',
    
    # Dzikir & Doa
    'lib/controller/list_doa_screen_controller.dart': 'lib/screen/dzikir&doa/',
    'lib/controller/dzikir_show_screen_controller.dart': 'lib/screen/dzikir&doa/',
    'lib/controller/dzikir_screen_controller.dart': 'lib/screen/dzikir&doa/',
    
    # Blog
    'lib/controller/blog_controller.dart': 'lib/screen/blog/',
    'lib/controller/blog_comment_controller.dart': 'lib/screen/blog/',
    'lib/controller/blog_detail_controller.dart': 'lib/screen/blog/',
    
    # Profile
    'lib/controller/change_profile_controller.dart': 'lib/screen/profile/',
    'lib/controller/profile_screen_controller.dart': 'lib/screen/profile/',
    
    # Leaderboard & Share
    'lib/controller/leaderboard_controller.dart': 'lib/screen/leaderboard/',
    'lib/controller/app_share_leaderboard_controller.dart': 'lib/screen/app_share_leaderboard/',
    
    # Others
    'lib/controller/delete_account_controller.dart': 'lib/screen/delete_account/',
    'lib/controller/notification_controller.dart': 'lib/screen/notification/',
    'lib/controller/theme_controller.dart': 'lib/screen/theme/',
    
    # Find Mosque
    'lib/controller/find_mosque_controller.dart': 'lib/screen/find_mosque/',
    
    # Pick Location (Move to mosque? or common? let's create a common/location folder, or just mosque. wait, pick_location_controller is probably used for mosques. I'll put it in mosque for now)
    'lib/controller/pick_location_controller.dart': 'lib/screen/mosque/',
}

import_replacements = {}

for src, dest_dir in moves.items():
    if not os.path.exists(src):
        print(f"Skipping {src}, file not found")
        continue
    
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)
        
    filename = os.path.basename(src)
    dest = os.path.join(dest_dir, filename)
    
    # Track import replacements
    # E.g. package:quran_app/controller/group/add_member_group_controller.dart
    #   -> package:quran_app/screen/group/add_member_group_controller.dart
    old_import = src.replace('lib/', 'quran_app/')
    new_import = dest.replace('lib/', 'quran_app/')
    import_replacements[old_import] = new_import
    
    print(f"Moving {src} to {dest}")
    shutil.move(src, dest)

print("\nUpdating imports...")
for filepath in glob.glob('lib/**/*.dart', recursive=True):
    with open(filepath, 'r') as f:
        content = f.read()
    
    changed = False
    for old_i, new_i in import_replacements.items():
        if old_i in content:
            content = content.replace(old_i, new_i)
            changed = True
            
    if changed:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated imports in {filepath}")

print("Done!")
