import 'package:phonecodes/phonecodes.dart';

/// Utility class for organizing countries by continent for easy selection
class CountryUtil {
  /// Map of continents to their respective countries
  static const Map<String, List<Country>> countriesByContinent = {
    'Africa': [
      Country.algeria,
      Country.angola,
      Country.benin,
      Country.botswana,
      Country.burkinaFaso,
      Country.burundi,
      Country.cameroon,
      Country.capeVerde,
      Country.centralAfricanRepublic,
      Country.chad,
      Country.comoros,
      Country.democraticRepublicOfTheCongo,
      Country.republicOfTheCongo,
      Country.djibouti,
      Country.egypt,
      Country.equatorialGuinea,
      Country.eritrea,
      Country.ethiopia,
      Country.gabon,
      Country.gambia,
      Country.ghana,
      Country.guinea,
      Country.guineaBissau,
      Country.kenya,
      Country.lesotho,
      Country.liberia,
      Country.libya,
      Country.madagascar,
      Country.malawi,
      Country.mali,
      Country.mauritania,
      Country.mauritius,
      Country.mayotte,
      Country.morocco,
      Country.mozambique,
      Country.namibia,
      Country.niger,
      Country.nigeria,
      Country.reunion,
      Country.rwanda,
      Country.saintHelena,
      Country.saintHelena247,
      Country.saoTomeAndPrincipe,
      Country.senegal,
      Country.seychelles,
      Country.sierraLeone,
      Country.somalia,
      Country.southAfrica,
      Country.southSudan,
      Country.sudan,
      Country.swaziland,
      Country.tanzania,
      Country.togo,
      Country.tunisia,
      Country.uganda,
      Country.zambia,
      Country.zimbabwe,
    ],
    'Asia': [
      Country.afghanistan,
      Country.armenia,
      Country.azerbaijan,
      Country.bahrain,
      Country.bangladesh,
      Country.bhutan,
      Country.brunei,
      Country.cambodia,
      Country.china,
      Country.christmasIsland,
      Country.cocosIslands,
      Country.georgia,
      Country.hongKong,
      Country.india,
      Country.indonesia,
      Country.iran,
      Country.iraq,
      Country.israel,
      Country.japan,
      Country.jordan,
      Country.kazakhstan,
      Country.kuwait,
      Country.kyrgyzstan,
      Country.laos,
      Country.lebanon,
      Country.macau,
      Country.malaysia,
      Country.maldives,
      Country.mongolia,
      Country.myanmar,
      Country.nepal,
      Country.northKorea,
      Country.oman,
      Country.pakistan,
      Country.palastinianTerritories,
      Country.philippines,
      Country.qatar,
      Country.saudiArabia,
      Country.singapore,
      Country.southKorea,
      Country.sriLanka,
      Country.syria,
      Country.taiwan,
      Country.tajikistan,
      Country.thailand,
      Country.timorLeste,
      Country.turkey,
      Country.turkmenistan,
      Country.unitedArabEmirates,
      Country.uzbekistan,
      Country.vietnam,
      Country.yemen,
    ],
    'Europe': [
      Country.alandIslands,
      Country.albania,
      Country.andorra,
      Country.austria,
      Country.belarus,
      Country.belgium,
      Country.bosniaAndHerzegovina,
      Country.bulgaria,
      Country.croatia,
      Country.cyprus,
      Country.czechRepublic,
      Country.denmark,
      Country.estonia,
      Country.faroeIslands,
      Country.finland,
      Country.france,
      Country.germany,
      Country.gibraltar,
      Country.greece,
      Country.greenland,
      Country.guernsey,
      Country.hungary,
      Country.iceland,
      Country.ireland,
      Country.italy,
      Country.jersey,
      Country.kosovo,
      Country.latvia,
      Country.liechtenstein,
      Country.lithuania,
      Country.luxembourg,
      Country.macedonia,
      Country.malta,
      Country.moldova,
      Country.monaco,
      Country.montenegro,
      Country.netherlands,
      Country.norway,
      Country.poland,
      Country.portugal,
      Country.romania,
      Country.russia,
      Country.sanMarino,
      Country.serbia,
      Country.slovakia,
      Country.slovenia,
      Country.spain,
      Country.svalbardAndJanMayen,
      Country.sweden,
      Country.switzerland,
      Country.ukraine,
      Country.unitedKingdom,
    ],
    'North America': [
      Country.anguilla,
      Country.antiguaAndBarbuda,
      Country.bahamas,
      Country.barbados,
      Country.belize,
      Country.bermuda,
      Country.britishVirginIslands,
      Country.canada,
      Country.caymanIslands,
      Country.costaRica,
      Country.cuba,
      Country.curacao,
      Country.dominica,
      Country.dominicanRepublic,
      Country.dominicanRepublic1829,
      Country.dominicanRepublic1849,
      Country.elSalvador,
      Country.grenada,
      Country.guadeloupe,
      Country.guatemala,
      Country.haiti,
      Country.honduras,
      Country.jamaica,
      Country.martinique,
      Country.mexico,
      Country.montserrat,
      Country.nicaragua,
      Country.panama,
      Country.saintBarthelemy,
      Country.saintKittsAndNevis,
      Country.saintLucia,
      Country.saintMartin,
      Country.saintPierreAndMiquelon,
      Country.saintVincentAndTheGrenadines,
      Country.sintMaarten,
      Country.trinidadAndTobago,
      Country.turksAndCaicosIslands,
      Country.unitedStates,
      Country.virginIslandsUS,
    ],
    'South America': [
      Country.argentina,
      Country.bolivia,
      Country.brazil,
      Country.chile,
      Country.colombia,
      Country.ecuador,
      Country.falklandIslands,
      Country.frenchGuiana,
      Country.guyana,
      Country.paraguay,
      Country.peru,
      Country.southGeorgiaAndTheSouthSandwichIslands,
      Country.suriname,
      Country.uruguay,
      Country.venezuela,
    ],
    'Oceania': [
      Country.americanSamoa,
      Country.australia,
      Country.cookIslands,
      Country.fiji,
      Country.frenchPolynesia,
      Country.guam,
      Country.kiribati,
      Country.marshallIslands,
      Country.micronesia,
      Country.nauru,
      Country.newCaledonia,
      Country.newZealand,
      Country.niue,
      Country.norfolkIsland,
      Country.northernMarianaIslands,
      Country.palau,
      Country.papuaNewGuinea,
      Country.pitcairnIslands,
      Country.samoa,
      Country.solomonIslands,
      Country.tokelau,
      Country.tonga,
      Country.tuvalu,
      Country.vanuatu,
      Country.wallisAndFutuna,
    ],
    'Other': [
      Country.britishIndianOceanTerritory,
      Country.globalMobileSatelliteSystem,
      Country.internationalNetworks,
      Country.internationalNetworks883,
      Country.puertoRico,
      Country.puertoRico1939,
    ],
  };

  /// Get all countries as a flat list
  static List<Country> get allCountries {
    return countriesByContinent.values
        .expand((countries) => countries)
        .toList();
  }

  /// Filter countries by search query
  static Iterable<MapEntry<String, List<Country>>> filteredCountries(
    String searchQuery,
  ) sync* {
    final query = searchQuery.toLowerCase();

    for (final entry in countriesByContinent.entries) {
      final filteredCountries =
          entry.value
              .where((country) => filterCountry(country, query))
              .toList();

      if (filteredCountries.isNotEmpty) {
        yield MapEntry(entry.key, filteredCountries);
      } else if (entry.key.toLowerCase().contains(query)) {
        yield entry;
      }
    }
  }

  /// Check if a country matches the search query
  static bool filterCountry(Country country, String searchQuery) {
    return country.name.toLowerCase().contains(searchQuery) ||
        country.code.toLowerCase().contains(searchQuery) ||
        country.dialCode.contains(searchQuery);
  }

  /// Get country by dial code
  static Country? getCountryByDialCode(String dialCode) {
    try {
      return allCountries.firstWhere((country) => country.dialCode == dialCode);
    } catch (e) {
      return null;
    }
  }

  /// Get country by country code
  static Country? getCountryByCode(String code) {
    try {
      return allCountries.firstWhere(
        (country) => country.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get country by name
  static Country? getCountryByName(String name) {
    try {
      return allCountries.firstWhere(
        (country) => country.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
