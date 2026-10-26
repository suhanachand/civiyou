
import SwiftUI

// MARK: - Opportunity Model

struct ArizonaOpportunity: Identifiable {
    let id: String
    let title: String
    let organization: String
    let city: String
    let category: String
    let minAge: Int?
    let maxAge: Int?
    let description: String
    let eligibility: String
    let applicationInfo: String
    let url: String
    let symbol: String
    let seasonal: Bool

    var ageDescription: String {
        if let minAge, let maxAge {
            return "Ages \(minAge)–\(maxAge)"
        }
        if let minAge {
            return "Ages \(minAge)+"
        }
        return "Age eligibility: confirm"
    }

    func ageMatches(_ age: Int?) -> Bool {
        guard let age else { return true }
        if let minAge, age < minAge { return false }
        if let maxAge, age > maxAge { return false }
        return true
    }

    var ageIsVerified: Bool {
        minAge != nil || maxAge != nil
    }
}

// MARK: - Curated Arizona Database

enum ArizonaOpportunityCatalog {

    private static func make(
        _ id: String,
        _ title: String,
        _ org: String,
        _ city: String,
        _ category: String,
        _ min: Int?,
        _ max: Int?,
        _ description: String,
        _ eligibility: String,
        _ application: String,
        _ url: String,
        _ symbol: String = "hands.sparkles",
        seasonal: Bool = false
    ) -> ArizonaOpportunity {
        ArizonaOpportunity(
            id: id,
            title: title,
            organization: org,
            city: city,
            category: category,
            minAge: min,
            maxAge: max,
            description: description,
            eligibility: eligibility,
            applicationInfo: application,
            url: url,
            symbol: symbol,
            seasonal: seasonal
        )
    }

    static let all: [ArizonaOpportunity] = [

        // MARK: PEORIA

        make(
            "peoria-book-buddies",
            "Book Buddies Reading Mentor",
            "Peoria Public Library",
            "Peoria",
            "Education",
            nil, nil,
            "Help younger children practice reading aloud and build confidence.",
            "Teen mentor opportunity. Confirm the current minimum age and next session.",
            "Check the library's Book Buddies program and mentor signup.",
            "https://peoria.polarislibrary.com/polaris/custom/youth_programs.aspx",
            "books.vertical.fill",
            seasonal: true
        ),

        make(
            "peoria-summer-library",
            "Summer Library Teen Volunteer",
            "Peoria Main Public Library",
            "Peoria",
            "Education",
            13, 17,
            "Assist with the Summer Reading Program and other library activities.",
            "The published 2024 program accepted ages 13–17. Future seasons may change requirements.",
            "Ask the Peoria Main Library about the next seasonal application period.",
            "https://www.peoriaed.com/Home/Components/News/News/5735/140",
            "book.fill",
            seasonal: true
        ),

        make(
            "peoria-parks",
            "Community Park & Trail Projects",
            "Peoria Parks and Recreation",
            "Peoria",
            "Environment",
            nil, nil,
            "Explore local trail stewardship and park improvement projects.",
            "Age rules depend on the project. Confirm youth supervision requirements.",
            "Contact the city's parks department about current organized service projects.",
            "https://www.peoriaaz.gov",
            "leaf.fill",
            seasonal: true
        ),

        // MARK: GLENDALE

        make(
            "glendale-library",
            "Library Volunteer",
            "Glendale Public Library",
            "Glendale",
            "Education",
            14, nil,
            "Help with programs, organizing materials, shelving and library operations.",
            "Ages 14+. Regular roles generally require 2–4 hours weekly and a longer commitment.",
            "Complete the library volunteer application. Current vacancies vary.",
            "https://library.glendaleaz.gov/Beyond-Books/Volunteering",
            "books.vertical.fill"
        ),

        make(
            "glendale-gold",
            "G.O.L.D. Teen Leadership",
            "Glendale Parks and Recreation",
            "Glendale",
            "Youth Leadership",
            15, 17,
            "Build recreation leadership and workplace skills alongside city staff.",
            "Ages 15–17. Placement and supervision are arranged through community centers.",
            "Contact a Glendale community center about the program.",
            "https://www.glendaleaz.gov/Explore/Parks-and-Recreation/Facilities-Centers/Community-Centers",
            "star.fill",
            seasonal: true
        ),

        make(
            "glendale-code",
            "City Code Compliance Volunteer",
            "City of Glendale",
            "Glendale",
            "Government",
            nil, nil,
            "Support neighborhood improvement and city administrative work.",
            "Some roles require a driver's license, screening and training. Not automatically suitable for minors.",
            "Review current positions and ask the city about eligibility.",
            "https://www.glendaleaz.gov/Community/City-Services/Code-Compliance/Volunteer-Opportunities",
            "building.2.fill"
        ),

        // MARK: SURPRISE

        make(
            "surprise-council",
            "Surprise Youth Council",
            "City of Surprise",
            "Surprise",
            "Youth Leadership",
            nil, nil,
            "Participate in civic leadership and community initiatives involving young residents.",
            "Youth program. Confirm current grade, residency and application requirements.",
            "Review the Youth Council page for membership information.",
            "https://surpriseaz.gov/surprise-youth-council",
            "person.3.fill",
            seasonal: true
        ),

        make(
            "surprise-teen-volunteer",
            "Teen Volunteer Program",
            "Surprise Parks and Recreation",
            "Surprise",
            "Volunteering",
            nil, nil,
            "Explore youth community service through the city's teen programming.",
            "Age eligibility and available placements depend on the program cycle.",
            "Visit the city's Youth & Teen Programs page.",
            "https://surpriseaz.gov/youth-teen-programs",
            "hands.sparkles",
            seasonal: true
        ),

        make(
            "surprise-city-volunteer",
            "City Department Volunteering",
            "City of Surprise",
            "Surprise",
            "Volunteering",
            nil, nil,
            "Explore public library, parks, transportation, arts and other city service opportunities.",
            "Requirements vary by department and position.",
            "Choose a department from the city's volunteer directory.",
            "https://surpriseaz.gov/volunteer",
            "building.2.fill"
        ),

        // MARK: GOODYEAR

        make(
            "goodyear-youth",
            "Goodyear Youth Commission",
            "City of Goodyear",
            "Goodyear",
            "Youth Leadership",
            nil, nil,
            "Advise city officials on youth issues, help plan events and participate in community leadership.",
            "Grades 9–12; eligible students generally live in Goodyear or attend school there.",
            "The published annual application period is April. Confirm the next cycle.",
            "https://www.goodyearaz.gov/our-city/residents/goodyear-youth-commission",
            "building.columns.fill",
            seasonal: true
        ),

        make(
            "goodyear-junior",
            "Junior Leader Summer Program",
            "Goodyear Parks and Recreation",
            "Goodyear",
            "Youth Leadership",
            13, 14,
            "Help support recreation activities while learning teamwork and leadership.",
            "Ages 13–14 for the published summer program.",
            "Check summer recreation registration for the next season.",
            "https://www.goodyearaz.gov/government/departments/parks-recreation/recreation-programs/break-camps",
            "figure.play",
            seasonal: true
        ),

        make(
            "goodyear-volunteers",
            "Goodyear Community Volunteering",
            "City of Goodyear",
            "Goodyear",
            "Volunteering",
            nil, nil,
            "Explore special events, parks, community projects and municipal volunteer roles.",
            "Each opportunity has separate age, screening and training requirements.",
            "Review the City Volunteer Program and active openings.",
            "https://www.goodyearaz.gov/government/departments/human-resources/volunteer-opportunities/volunteer-program",
            "hand.raised.fill"
        ),

        // MARK: PHOENIX

        make(
            "phoenix-yec",
            "Youth and Education Commission",
            "City of Phoenix",
            "Phoenix",
            "Youth Leadership",
            nil, nil,
            "Contribute youth perspectives to the city's educational priorities and programs.",
            "High-school-aged youth are invited to explore membership. Appointments and vacancies vary.",
            "Review the city application guidance.",
            "https://www.phoenix.gov/administration/departments/education/get-involved.html",
            "graduationcap.fill",
            seasonal: true
        ),

        make(
            "phoenix-library",
            "Summer Teen Library Volunteer",
            "Phoenix Public Library",
            "Phoenix",
            "Education",
            13, 17,
            "Help library visitors and support youth summer reading activities.",
            "The 2026 program was advertised for ages 13–17. Seasonal applications may be closed.",
            "Check the library's next summer volunteer recruitment.",
            "https://www.phoenix.gov/newsroom/public-library-news/applications-open-for-phoenix-public-library-s-2026-teen-volunte.html",
            "books.vertical.fill",
            seasonal: true
        ),

        make(
            "phoenix-science",
            "Science Center Volunteer",
            "Arizona Science Center",
            "Phoenix",
            "STEM",
            15, nil,
            "Assist with science exhibitions, demonstrations and visitor experiences.",
            "Ages 15+. Application, interview, orientation and service commitment apply.",
            "Apply through the Science Center's volunteer program.",
            "https://www.azscience.org/support/volunteer-opportunities/",
            "atom"
        ),

        make(
            "phoenix-humane",
            "Animal Shelter Volunteer",
            "Arizona Humane Society",
            "Phoenix",
            "Animals",
            16, nil,
            "Help support shelter programs and animal welfare initiatives.",
            "Ages 16+. Standard positions require a regular commitment; one-time roles may differ.",
            "Review volunteer options and available placements.",
            "https://www.azhumane.org/become-a-volunteer/",
            "pawprint.fill"
        ),

        make(
            "phoenix-neighborhood",
            "Neighborhood Improvement Projects",
            "City of Phoenix",
            "Phoenix",
            "Community",
            nil, nil,
            "Explore opportunities to support neighborhood improvements and community events.",
            "Project eligibility varies. Some roles may accept teen volunteers.",
            "Contact Neighborhood Services to confirm current projects.",
            "https://www.phoenix.gov/administration/departments/nsd/get-involved/volunteer-programs.html",
            "house.fill"
        ),

        // MARK: TEMPE

        make(
            "tempe-youth",
            "Mayor's Youth Advisory Commission",
            "City of Tempe",
            "Tempe",
            "Youth Leadership",
            nil, nil,
            "Advise city leaders about issues affecting young residents.",
            "Youth commission membership has appointment and eligibility rules.",
            "Review the commission's membership and application information.",
            "https://www.tempe.gov/government/city-clerk-s-office/boards-and-commissions/active-boards-commissions-committees-and-other-public-bodies/mayor-s-youth-advisory-commission",
            "person.3.fill",
            seasonal: true
        ),

        make(
            "tempe-museum",
            "Tempe History Museum Volunteer",
            "Tempe History Museum",
            "Tempe",
            "Arts & Culture",
            nil, nil,
            "Support museum events, public programs and local history education.",
            "Age and skills depend on the role. Some specialties are currently closed.",
            "Check the museum's Events volunteer positions.",
            "https://www.tempe.gov/government/community-services/tempe-history-museum/volunteering",
            "building.columns.fill"
        ),

        make(
            "tempe-city",
            "City of Tempe Volunteer Program",
            "City of Tempe",
            "Tempe",
            "Volunteering",
            nil, nil,
            "Browse public service projects, environmental activities and city programs.",
            "Age, training and screening requirements depend on the assignment.",
            "Register through Tempe's Volunteer Office.",
            "https://www.tempe.gov/government/community-services/volunteer",
            "hands.sparkles"
        ),

        // MARK: MESA

        make(
            "mesa-foodbank",
            "Food Bank Volunteer",
            "United Food Bank",
            "Mesa",
            "Food Security",
            5, nil,
            "Build food bags, sort food donations and support hunger relief.",
            "Ages 5–15 can join designated food-bag shifts. Ages 16–17 can volunteer independently with a signed waiver.",
            "Register for an age-appropriate shift.",
            "https://unitedfoodbank.org/volunteer/",
            "shippingbox.fill"
        ),

        make(
            "mesa-teen-leadership",
            "Teen Leadership Training",
            "Mesa Parks and Recreation",
            "Mesa",
            "Youth Leadership",
            nil, nil,
            "Support summer recreation camps while developing communication and leadership skills.",
            "Teen placement program. Confirm current age limits and enrollment.",
            "Contact the Parks and Recreation volunteer coordinator.",
            "https://www.mesaaz.gov/Activities-Culture/Parks-Recreation-and-Community-Facilities/Volunteers-and-Internships",
            "figure.run",
            seasonal: true
        ),

        make(
            "mesa-moves",
            "MesaMoves Outreach Volunteer",
            "City of Mesa Transportation",
            "Mesa",
            "Community",
            13, nil,
            "Help prepare materials and educational resources for transportation safety outreach.",
            "Age 16+ may work independently; ages 13–15 require adult supervision and permission.",
            "Review the MesaMoves volunteer instructions.",
            "https://www.mesaaz.gov/Resident-Resources/Streets-Transportation/MesaMoves/Get-Involved",
            "bicycle"
        ),

        make(
            "mesa-citywide",
            "Mesa Citywide Service Projects",
            "City of Mesa",
            "Mesa",
            "Volunteering",
            nil, nil,
            "Explore community cleanups, city events and special service projects.",
            "Age restrictions depend on the individual event.",
            "Join the city's volunteer interest list.",
            "https://www.mesaaz.gov/Resident-Resources/Citywide-Volunteer-Program",
            "leaf.fill"
        ),

        // MARK: CHANDLER

        make(
            "chandler-library",
            "Teen Library Volunteer",
            "Chandler Public Library",
            "Chandler",
            "Education",
            nil, nil,
            "Help with youth programs, library events, Summer Reading and Teen Advisory activities.",
            "Teen opportunities are listed by the city. Confirm age and recruitment requirements.",
            "Contact Chandler Public Library's volunteer coordinator.",
            "https://www.chandleraz.gov/chandler-a-z/volunteer-opportunities/at-the-city",
            "books.vertical.fill",
            seasonal: true
        ),

        make(
            "chandler-events",
            "Community Events Volunteer",
            "City of Chandler",
            "Chandler",
            "Arts & Culture",
            nil, nil,
            "Help support city cultural festivals and collaborative community events.",
            "Volunteer eligibility varies by event and role.",
            "Check the Connection & Impact volunteer opportunities.",
            "https://www.chandleraz.gov/chandler-a-z/volunteer-opportunities/at-the-city",
            "person.3.fill"
        ),

        make(
            "chandler-recreation",
            "Teen Recreation Opportunities",
            "Chandler Recreation",
            "Chandler",
            "Community",
            nil, nil,
            "Explore youth volunteer and recreation leadership opportunities.",
            "Program requirements and availability vary seasonally.",
            "Review Chandler's official teen program directory.",
            "https://www.chandleraz.gov/index.php/explore/chandler-recreation/programs-and-activities/teen-programs",
            "figure.play",
            seasonal: true
        ),

        // MARK: SCOTTSDALE

        make(
            "scottsdale-youth",
            "Scottsdale Mayor's Youth Council",
            "City of Scottsdale",
            "Scottsdale",
            "Youth Leadership",
            nil, nil,
            "Participate in youth civic leadership, city discussions and service activities.",
            "For Scottsdale high school youth. Check appointment and attendance requirements.",
            "Review the Youth Council application information.",
            "https://www.scottsdaleaz.gov/council/mayor-lisa-borowsky/mayors-youth-council",
            "building.columns.fill",
            seasonal: true
        ),

        make(
            "scottsdale-tab",
            "Library Teen Advisory Board",
            "Scottsdale Public Library",
            "Scottsdale",
            "Education",
            12, 18,
            "Help plan teen library programs and participate in library service projects.",
            "Published sessions are for ages 12–18. Check current library meeting dates.",
            "Review the teen program calendar.",
            "https://www.scottsdaleaz.gov/youth-teen-programs",
            "books.vertical.fill"
        ),

        make(
            "scottsdale-volunteer",
            "City Volunteer Opportunities",
            "City of Scottsdale",
            "Scottsdale",
            "Volunteering",
            nil, nil,
            "Explore library, cultural, recreation and community assistance volunteering.",
            "Each role has individual age and training requirements.",
            "Search the city's volunteer directory.",
            "https://www.scottsdaleaz.gov/volunteer",
            "hands.sparkles"
        ),

        // MARK: GILBERT

        make(
            "gilbert-myac",
            "Mayor's Youth Advisory Committee",
            "Town of Gilbert",
            "Gilbert",
            "Youth Leadership",
            14, 18,
            "Provide feedback to town leadership and help with civic initiatives.",
            "Ages 14–18, grades 9–12, living in or attending school in Gilbert. The 2026–27 application period is closed.",
            "Review future application cycles and Student Government Day.",
            "https://www.gilbertaz.gov/residents/town-programs/mayor-s-youth-advisory-council",
            "person.3.fill",
            seasonal: true
        ),

        make(
            "gilbert-service",
            "Day of Service",
            "Town of Gilbert",
            "Gilbert",
            "Community",
            nil, nil,
            "Help residents needing assistance with appropriate household and yardwork tasks.",
            "All ages may participate with applicable waivers; under 15 requires an accompanying adult.",
            "Check the next scheduled Day of Service.",
            "https://www.gilbertaz.gov/community/residents/volunteer/day-of-service-resident-application",
            "house.fill",
            seasonal: true
        ),

        make(
            "gilbert-riparian",
            "Riparian Preserve Volunteer",
            "Gilbert Parks and Recreation",
            "Gilbert",
            "Environment",
            nil, nil,
            "Participate in conservation and park volunteer days.",
            "Project age limits depend on the activity. Select events run seasonally.",
            "Check the town's volunteer calendar.",
            "https://www.gilbertaz.gov/community/residents/volunteer",
            "leaf.fill",
            seasonal: true
        ),

        make(
            "gilbert-parks",
            "Parks & Recreation Volunteer",
            "Town of Gilbert",
            "Gilbert",
            "Volunteering",
            nil, nil,
            "Help with recreation, events, park stewardship and community programs.",
            "Role-specific requirements apply.",
            "Complete the town volunteer application.",
            "https://www.gilbertaz.gov/departments/parks-and-recreation/volunteer",
            "figure.walk"
        ),

        // MARK: REGIONAL OPPORTUNITIES

        make(
            "metro-handson",
            "HandsOn Greater Phoenix",
            "HandsOn Greater Phoenix",
            "Phoenix Metro",
            "Volunteering",
            13, nil,
            "Browse service projects with community organizations throughout the Valley.",
            "Youth roles vary. Ages 13–15 generally need an accompanying adult; 16–17-year-olds may need a youth waiver.",
            "Register, complete any required orientation and check individual projects.",
            "https://www.handsonphoenix.org/ages13_18",
            "hands.sparkles"
        ),

        make(
            "metro-habitat-restore",
            "Habitat ReStore Volunteer",
            "Habitat for Humanity Central Arizona",
            "Phoenix Metro",
            "Housing",
            15, nil,
            "Assist with organizing merchandise and supporting Habitat ReStore operations.",
            "Ages 15+. Minors need a signed waiver and face task restrictions.",
            "Apply through Habitat's volunteer program.",
            "https://habitatcaz.org/volunteer/",
            "house.fill"
        ),

        make(
            "metro-habitat-construction",
            "Habitat Construction Volunteer",
            "Habitat for Humanity Central Arizona",
            "Phoenix Metro",
            "Housing",
            16, nil,
            "Participate in suitable supervised housing construction service activities.",
            "Ages 16+. Minors are restricted from certain construction tasks and equipment.",
            "Review youth restrictions and approved roles before signing up.",
            "https://habitatcaz.org/volunteer/",
            "hammer.fill"
        )
    ]
}

// MARK: - Saved Search Preferences

private struct OpportunityPreferences: Codable {
    var age = ""
    var zip = ""
    var city = "All cities"
    var category = "All interests"
    var showUnconfirmedAge = true
}

// MARK: - Opportunity Finder

struct ArizonaOpportunitiesView: View {

    @AppStorage("civi.opportunities.preferences")
    private var preferencesData = Data()

    @State private var preferences = OpportunityPreferences()
    @State private var searchText = ""
    @State private var hasLoaded = false

    @AppStorage("civi.agePreference")
    private var aiAgePreference = 0

    private let cities = [
        "All cities",
        "Peoria",
        "Glendale",
        "Surprise",
        "Goodyear",
        "Phoenix",
        "Tempe",
        "Mesa",
        "Chandler",
        "Scottsdale",
        "Gilbert"
    ]

    private let categories = [
        "All interests",
        "Youth Leadership",
        "Volunteering",
        "Education",
        "Community",
        "Government",
        "Environment",
        "Food Security",
        "STEM",
        "Animals",
        "Arts & Culture",
        "Housing"
    ]

    private var selectedAge: Int? {
        guard let age = Int(preferences.age),
              (10...100).contains(age) else {
            return nil
        }
        return age
    }

    private var validZIP: Bool {
        preferences.zip.count == 5 &&
        preferences.zip.allSatisfy(\.isNumber)
    }

    private var inferredCity: String? {
        guard validZIP,
              let prefix = Int(preferences.zip.prefix(3))
        else { return nil }

        // Broad geographic hints, not exact ZIP geocoding.
        switch prefix {
        case 850:
            return "Phoenix"
        case 851:
            return "Gilbert"
        case 852:
            return "Mesa"
        case 853:
            return "Peoria"
        default:
            return nil
        }
    }

    private var selectedCity: String? {
        if preferences.city != "All cities" {
            return preferences.city
        }
        return inferredCity
    }

    private var matching: [ArizonaOpportunity] {
        ArizonaOpportunityCatalog.all.filter { item in

            let searchMatches =
                searchText.isEmpty ||
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.organization.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText)

            let categoryMatches =
                preferences.category == "All interests" ||
                item.category == preferences.category

            let ageMatches = item.ageMatches(selectedAge)

            let ageConfidenceMatches =
                selectedAge == nil ||
                preferences.showUnconfirmedAge ||
                item.ageIsVerified

            return searchMatches &&
                categoryMatches &&
                ageMatches &&
                ageConfidenceMatches

        }
        .sorted {
            let firstScore = relevance($0)
            let secondScore = relevance($1)

            if firstScore != secondScore {
                return firstScore > secondScore
            }

            return $0.title < $1.title
        }
    }

    private func relevance(
        _ item: ArizonaOpportunity
    ) -> Int {
        var score = 0

        if let city = selectedCity {
            if item.city == city {
                score += 100
            } else if item.city == "Phoenix Metro" {
                score += 35
            }
        }

        if let age = selectedAge {
            if item.ageIsVerified && item.ageMatches(age) {
                score += 15
            }
        }

        if !item.seasonal {
            score += 5
        }

        return score
    }

    private var nearbyResultsCount: Int {
        matching.filter {
            guard let city = selectedCity else { return false }
            return $0.city == city
        }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                header

                preferenceCard

                resultsHeader

                if matching.isEmpty {
                    ContentUnavailableView(
                        "No matching programs",
                        systemImage: "magnifyingglass",
                        description: Text(
                            "Try another age, interest, or search term."
                        )
                    )
                }

                ForEach(matching) { opportunity in
                    opportunityCard(opportunity)
                }

                informationCard
            }
            .padding(20)
        }
        .background(CiviYouTheme.cream)
        .navigationTitle("Arizona Opportunities")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            loadPreferences()
        }
        .onChange(of: preferences.age) { _, _ in
            savePreferences()
        }
        .onChange(of: preferences.zip) { _, _ in
            savePreferences()
        }
        .onChange(of: preferences.city) { _, _ in
            savePreferences()
        }
        .onChange(of: preferences.category) { _, _ in
            savePreferences()
        }
        .onChange(of: preferences.showUnconfirmedAge) { _, _ in
            savePreferences()
        }
    }

    // MARK: - Header

    private var header: some View {
        CiviCard(color: CiviYouTheme.yellow) {
            VStack(alignment: .leading, spacing: 12) {

                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 38))

                Text("Find Your Opportunity")
                    .font(CiviYouTheme.heading(30))

                Text(
                    "Find local volunteering, youth leadership, and community programs matched to your interests."
                )
                .font(CiviYouTheme.body(15))

                CiviPill(
                    title: "Arizona civic opportunities",
                    color: CiviYouTheme.white
                )
            }
            .foregroundStyle(CiviYouTheme.charcoal)
        }
    }

    // MARK: - Filters

    private var preferenceCard: some View {
        CiviCard {
            VStack(alignment: .leading, spacing: 14) {

                Label(
                    "Personalize your opportunities",
                    systemImage: "slider.horizontal.3"
                )
                .font(CiviYouTheme.heading(21))

                TextField(
                    "Search programs or organizations",
                    text: $searchText
                )
                .textFieldStyle(.roundedBorder)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your age")
                            .font(.caption.bold())

                        TextField(
                            "e.g. 16",
                            text: $preferences.age
                        )
                        .textFieldStyle(.roundedBorder)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .onChange(of: preferences.age) { _, value in
                            preferences.age = String(
                                value.filter(\.isNumber).prefix(3)
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ZIP code")
                            .font(.caption.bold())

                        TextField(
                            "e.g. 85382",
                            text: $preferences.zip
                        )
                        .textFieldStyle(.roundedBorder)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .onChange(of: preferences.zip) { _, value in
                            preferences.zip = String(
                                value.filter(\.isNumber).prefix(5)
                            )
                        }
                    }
                }

                if !preferences.zip.isEmpty {
                    Text(
                        "ZIP codes provide approximate regional suggestions only. Select your city below for more reliable sorting."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Picker(
                    "Your city",
                    selection: $preferences.city
                ) {
                    ForEach(cities, id: \.self) { city in
                        Text(city).tag(city)
                    }
                }

                Picker(
                    "Your interests",
                    selection: $preferences.category
                ) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }

                Toggle(
                    "Include programs with unconfirmed age eligibility",
                    isOn: $preferences.showUnconfirmedAge
                )
                .font(.subheadline)
                .tint(CiviYouTheme.charcoal)

                Button("Clear filters") {
                    preferences = OpportunityPreferences()
                    searchText = ""
                    savePreferences()
                }
                .font(.subheadline.bold())

                Text(
                    "Your preferences are saved on this device. CiviYou doesn't need your street address."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Results Header

    private var resultsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("\(matching.count) matching programs")
                .font(CiviYouTheme.heading(23))

            if let city = selectedCity {
                Text(
                    "\(nearbyResultsCount) specifically listed in \(city). Regional programs and other cities are shown afterward."
                )
                .font(CiviYouTheme.body(13))
                .foregroundStyle(.secondary)
            }

            Text(
                "Programs are ranked by location and eligibility, not confirmed open seats."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Program Card

    private func opportunityCard(
        _ item: ArizonaOpportunity
    ) -> some View {
        CiviCard(color: CiviYouTheme.white) {
            VStack(alignment: .leading, spacing: 13) {

                HStack(alignment: .top, spacing: 12) {

                    Image(systemName: item.symbol)
                        .font(.system(size: 27))
                        .frame(width: 35)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(CiviYouTheme.heading(21))

                        Text(item.organization)
                            .font(.subheadline.bold())
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    CiviPill(
                        title: item.category,
                        color: CiviYouTheme.blue
                    )

                    if item.seasonal {
                        CiviPill(
                            title: "Seasonal",
                            color: CiviYouTheme.yellow
                        )
                    }
                }

                Text(item.description)
                    .font(CiviYouTheme.body(14))

                Divider()

                Label(
                    item.city,
                    systemImage: "mappin.circle"
                )
                .font(.subheadline)

                Label(
                    item.ageDescription,
                    systemImage: "person.crop.circle"
                )
                .font(.subheadline)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Eligibility")
                        .font(.subheadline.bold())

                    Text(item.eligibility)
                        .font(CiviYouTheme.body(13))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("How to participate")
                        .font(.subheadline.bold())

                    Text(item.applicationInfo)
                        .font(CiviYouTheme.body(13))
                }

                if let url = URL(string: item.url),
                   url.scheme == "https" {

                    Link(destination: url) {
                        HStack {
                            Image(systemName: "arrow.up.right")

                            Text("View official program")

                            Spacer()
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(CiviYouTheme.charcoal)
                        .padding(13)
                        .background(
                            CiviYouTheme.yellow,
                            in: RoundedRectangle(cornerRadius: 13)
                        )
                    }
                }
            }
            .foregroundStyle(CiviYouTheme.charcoal)
        }
    }

    // MARK: - Directory Explanation

    private var informationCard: some View {
        CiviCard(color: CiviYouTheme.blue.opacity(0.35)) {
            VStack(alignment: .leading, spacing: 10) {

                Label(
                    "About this directory",
                    systemImage: "info.circle.fill"
                )
                .font(.subheadline.bold())

                Text(
                    "This directory contains curated programs, including recurring opportunities and seasonal applications. Inclusion does not mean a position is currently open."
                )
                .font(CiviYouTheme.body(13))

                Text(
                    "Where exact age requirements aren't confirmed, the program remains labeled for verification. Other city programs may be shown because you can sometimes participate outside your home city."
                )
                .font(CiviYouTheme.body(13))

                Text(
                    "Last research review: October 2026. Confirm eligibility, application deadlines, supervision, and availability on the organizer's official website."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Persistence

    private func loadPreferences() {
        guard !hasLoaded else { return }
        hasLoaded = true

        if let saved = try? JSONDecoder().decode(
            OpportunityPreferences.self,
            from: preferencesData
        ) {
            preferences = saved
        } else if (10...100).contains(aiAgePreference) {
            preferences.age = String(aiAgePreference)
        }
    }

    private func savePreferences() {
        if let data = try? JSONEncoder().encode(preferences) {
            preferencesData = data
        }
    }
}
//
//  ArizonaOpportunitiesView.swift
//  CiviYou
//
//  Created by Ruchita Tayal on 10/24/26.
//

