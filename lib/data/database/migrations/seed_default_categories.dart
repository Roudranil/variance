// lib/data/database/migrations/seed_default_categories.dart
//
// Default category seed data for Variance (CAT-02).
//
// PRD §5.6.1 and §5.2.4 define the default category taxonomy:
//   - Two trees: income and expense.
//   - Two-level hierarchy: parent categories may have child subcategories.
//   - Protected rows: Balance Adjustment parents and children (BAI/BAE) plus
//     "Fees & Charges" under the Financial expense parent are is_protected=1.
//   - Leaf parents (Gift, Other income) have no subcategories by design.
//   - icon_ref for non-protected categories is 'category' (placeholder until
//     the curated icon list TC-014 is approved by the founder).
//   - icon_ref for protected Balance Adjustment rows is 'balance' per PRD §5.2.4.6.
//
// Inserted via INSERT OR IGNORE for idempotency (safe to re-run on an
// already-seeded database without producing duplicate rows).
//
// UUIDs are hard-coded so that the set is stable across re-installs and
// test runs. They were generated once with Uuid().v4() and frozen here.
//
// Test cases (see test/data/database/category_seed_test.dart):
//   1. All expected income parent categories are present after onCreate
//   2. All expected expense parent categories are present after onCreate
//   3. All expected income subcategories are present
//   4. All expected expense subcategories are present
//   5. Protected rows have is_protected = 1
//   6. Non-protected rows have is_protected = 0
//   7. Running seed twice produces no duplicate rows (idempotency)

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart';

// ---------------------------------------------------------------------------
// icon_ref constants
// ---------------------------------------------------------------------------

/// Placeholder icon ref used for all non-protected default categories.
/// Replaced by the curated icon ref after TC-014 is approved.
const _kIconPlaceholder = 'category';

/// Icon ref for Balance Adjustment protected categories (PRD §5.2.4.6).
const _kIconBalance = 'balance';

// ---------------------------------------------------------------------------
// Stable UUIDs for all default categories
// ---------------------------------------------------------------------------
// Income parents
const _kIncomeStandard = 'c001-std-inc-0000-000000000001';
const _kIncomeGift = 'c001-gft-inc-0000-000000000002';
const _kIncomeRepayment = 'c001-rep-inc-0000-000000000003';
const _kIncomeOther = 'c001-oth-inc-0000-000000000004';
const _kIncomeBalAdj = 'c001-bai-inc-0000-000000000005';

// Income children — Standard
const _kIncomeSalary = 'c002-sal-inc-0000-000000000011';
const _kIncomeBonus = 'c002-bon-inc-0000-000000000012';
const _kIncomeAllowance = 'c002-alw-inc-0000-000000000013';
const _kIncomeReimbursement = 'c002-rei-inc-0000-000000000014';
const _kIncomeScholarship = 'c002-sch-inc-0000-000000000015';
const _kIncomeEpf = 'c002-epf-inc-0000-000000000016';
const _kIncomePension = 'c002-pen-inc-0000-000000000017';

// Income children — Repayment
const _kIncomeLoans = 'c002-loa-inc-0000-000000000021';
const _kIncomeSplitwise = 'c002-spl-inc-0000-000000000022';
const _kIncomeRefund = 'c002-ref-inc-0000-000000000023';

// Income children — Balance Adjustment child (BAI)
const _kIncomeBai = 'c002-bai-inc-0000-000000000031';

// Expense parents
const _kExpFood = 'c001-fod-exp-0000-000000000101';
const _kExpTransportation = 'c001-trn-exp-0000-000000000102';
const _kExpHousehold = 'c001-hse-exp-0000-000000000103';
const _kExpTravels = 'c001-trv-exp-0000-000000000104';
const _kExpApparel = 'c001-apr-exp-0000-000000000105';
const _kExpHealth = 'c001-hlt-exp-0000-000000000106';
const _kExpSelf = 'c001-slf-exp-0000-000000000107';
const _kExpSocial = 'c001-soc-exp-0000-000000000108';
const _kExpStationery = 'c001-sta-exp-0000-000000000109';
const _kExpCulture = 'c001-clt-exp-0000-000000000110';
const _kExpFinancial = 'c001-fin-exp-0000-000000000111';
const _kExpEducation = 'c001-edu-exp-0000-000000000112';
const _kExpLoan = 'c001-lon-exp-0000-000000000113';
const _kExpFriendsFamily = 'c001-frf-exp-0000-000000000114';
const _kExpOther = 'c001-oth-exp-0000-000000000115';
const _kExpBalAdj = 'c001-bae-exp-0000-000000000116';

// Expense children — Food
const _kExpFoodLunch = 'c002-fod-lnc-0000-000000001001';
const _kExpFoodDinner = 'c002-fod-din-0000-000000001002';
const _kExpFoodBreakfast = 'c002-fod-brf-0000-000000001003';
const _kExpFoodSnacks = 'c002-fod-snk-0000-000000001004';
const _kExpFoodWater = 'c002-fod-wtr-0000-000000001005';
const _kExpFoodEatingOut = 'c002-fod-eat-0000-000000001006';
const _kExpFoodGroceries = 'c002-fod-gro-0000-000000001007';
const _kExpFoodSweets = 'c002-fod-swt-0000-000000001008';
const _kExpFoodDrinks = 'c002-fod-drk-0000-000000001009';
const _kExpFoodOther = 'c002-fod-oth-0000-000000001010';

// Expense children — Transportation
const _kExpTrnBike = 'c002-trn-bik-0000-000000002001';
const _kExpTrnAuto = 'c002-trn-aut-0000-000000002002';
const _kExpTrnCab = 'c002-trn-cab-0000-000000002003';
const _kExpTrnBus = 'c002-trn-bus-0000-000000002004';
const _kExpTrnMetro = 'c002-trn-mtr-0000-000000002005';
const _kExpTrnFuel = 'c002-trn-ful-0000-000000002006';
const _kExpTrnParking = 'c002-trn-prk-0000-000000002007';
const _kExpTrnTolls = 'c002-trn-tol-0000-000000002008';
const _kExpTrnOther = 'c002-trn-oth-0000-000000002009';

// Expense children — Household
const _kExpHseRent = 'c002-hse-rnt-0000-000000003001';
const _kExpHseAppliances = 'c002-hse-app-0000-000000003002';
const _kExpHseToiletries = 'c002-hse-tlt-0000-000000003003';
const _kExpHseRepairs = 'c002-hse-rep-0000-000000003004';
const _kExpHseMarketing = 'c002-hse-mkt-0000-000000003005';
const _kExpHseWater = 'c002-hse-wtr-0000-000000003006';
const _kExpHseCleaning = 'c002-hse-cln-0000-000000003007';
const _kExpHseFurniture = 'c002-hse-fur-0000-000000003008';
const _kExpHseCookMaid = 'c002-hse-mdk-0000-000000003009';
const _kExpHseKitchen = 'c002-hse-kit-0000-000000003010';
const _kExpHseAccessories = 'c002-hse-acc-0000-000000003011';
const _kExpHseOther = 'c002-hse-oth-0000-000000003012';

// Expense children — Travels
const _kExpTrvTrain = 'c002-trv-trn-0000-000000004001';
const _kExpTrvFlight = 'c002-trv-flt-0000-000000004002';
const _kExpTrvHotel = 'c002-trv-htl-0000-000000004003';
const _kExpTrvEntryFee = 'c002-trv-ent-0000-000000004004';
const _kExpTrvFood = 'c002-trv-fod-0000-000000004005';
const _kExpTrvTransport = 'c002-trv-trp-0000-000000004006';
const _kExpTrvGifts = 'c002-trv-gft-0000-000000004007';
const _kExpTrvOther = 'c002-trv-oth-0000-000000004008';

// Expense children — Apparel
const _kExpAprClothing = 'c002-apr-clt-0000-000000005001';
const _kExpAprFashion = 'c002-apr-fsh-0000-000000005002';
const _kExpAprShoes = 'c002-apr-sho-0000-000000005003';
const _kExpAprLaundry = 'c002-apr-lnd-0000-000000005004';
const _kExpAprJewellery = 'c002-apr-jwl-0000-000000005005';
const _kExpAprAccessories = 'c002-apr-acc-0000-000000005006';
const _kExpAprOther = 'c002-apr-oth-0000-000000005007';

// Expense children — Health
const _kExpHltDoctor = 'c002-hlt-doc-0000-000000006001';
const _kExpHltHospital = 'c002-hlt-hsp-0000-000000006002';
const _kExpHltMedicine = 'c002-hlt-med-0000-000000006003';
const _kExpHltGym = 'c002-hlt-gym-0000-000000006004';
const _kExpHltHospTransport = 'c002-hlt-htr-0000-000000006005';
const _kExpHltHospFood = 'c002-hlt-hfd-0000-000000006006';
const _kExpHltAmbulance = 'c002-hlt-amb-0000-000000006007';
const _kExpHltTests = 'c002-hlt-tst-0000-000000006008';
const _kExpHltOther = 'c002-hlt-oth-0000-000000006009';

// Expense children — Self
const _kExpSlfHaircut = 'c002-slf-hrc-0000-000000007001';
const _kExpSlfElecAcc = 'c002-slf-ela-0000-000000007002';
const _kExpSlfRepair = 'c002-slf-rep-0000-000000007003';
const _kExpSlfSubscriptions = 'c002-slf-sub-0000-000000007004';
const _kExpSlfTrip = 'c002-slf-trp-0000-000000007005';
const _kExpSlfParty = 'c002-slf-pty-0000-000000007006';
const _kExpSlfBooks = 'c002-slf-bks-0000-000000007007';
const _kExpSlfToys = 'c002-slf-toy-0000-000000007008';
const _kExpSlfGlasses = 'c002-slf-gls-0000-000000007009';
const _kExpSlfGames = 'c002-slf-gam-0000-000000007010';
const _kExpSlfOther = 'c002-slf-oth-0000-000000007011';

// Expense children — Social
const _kExpSocMovie = 'c002-soc-mov-0000-000000008001';
const _kExpSocTreat = 'c002-soc-trt-0000-000000008002';
const _kExpSocOuting = 'c002-soc-out-0000-000000008003';
const _kExpSocGift = 'c002-soc-gft-0000-000000008004';
const _kExpSocOther = 'c002-soc-oth-0000-000000008005';

// Expense children — Stationery
const _kExpStaBooks = 'c002-sta-bks-0000-000000009001';
const _kExpStaArt = 'c002-sta-art-0000-000000009002';
const _kExpStaCraft = 'c002-sta-crf-0000-000000009003';
const _kExpStaOther = 'c002-sta-oth-0000-000000009004';

// Expense children — Culture
const _kExpCltMusic = 'c002-clt-mus-0000-000000010001';
const _kExpCltConcert = 'c002-clt-con-0000-000000010002';
const _kExpCltMuseum = 'c002-clt-msr-0000-000000010003';
const _kExpCltFestival = 'c002-clt-fst-0000-000000010004';
const _kExpCltPujo = 'c002-clt-pjo-0000-000000010005';
const _kExpCltOther = 'c002-clt-oth-0000-000000010006';

// Expense children — Financial
const _kExpFinMobileBill = 'c002-fin-mob-0000-000000011001';
const _kExpFinWifiBill = 'c002-fin-wif-0000-000000011002';
const _kExpFinElecBill = 'c002-fin-elc-0000-000000011003';
const _kExpFinInsurance = 'c002-fin-ins-0000-000000011004';
const _kExpFinTax = 'c002-fin-tax-0000-000000011005';
const _kExpFinInvestments = 'c002-fin-inv-0000-000000011006';
const _kExpFinFeesCharges = 'c002-fin-fch-0000-000000011007'; // protected
const _kExpFinOther = 'c002-fin-oth-0000-000000011008';

// Expense children — Education
const _kExpEduAppFees = 'c002-edu-apf-0000-000000012001';
const _kExpEduTextbooks = 'c002-edu-txt-0000-000000012002';
const _kExpEduSupplies = 'c002-edu-sup-0000-000000012003';
const _kExpEduTuition = 'c002-edu-tui-0000-000000012004';
const _kExpEduOther = 'c002-edu-oth-0000-000000012005';

// Expense children — Loan
const _kExpLonEduLoan = 'c002-lon-edu-0000-000000013001';
const _kExpLonHomeLoan = 'c002-lon-hom-0000-000000013002';
const _kExpLonPersonal = 'c002-lon-per-0000-000000013003';
const _kExpLonSpliwise = 'c002-lon-spl-0000-000000013004';
const _kExpLonOther = 'c002-lon-oth-0000-000000013005';

// Expense children — Friends & Family
const _kExpFrfFriends = 'c002-frf-fri-0000-000000014001';
const _kExpFrfParents = 'c002-frf-par-0000-000000014002';
const _kExpFrfOther = 'c002-frf-oth-0000-000000014003';

// Expense children — Other
const _kExpOthHome = 'c002-oth-hom-0000-000000015001';
const _kExpOthCharity = 'c002-oth-chr-0000-000000015002';
const _kExpOthOther = 'c002-oth-oth-0000-000000015003';

// Expense children — Balance Adjustment child (BAE)
const _kExpBae = 'c002-bae-exp-0000-000000016001';

// ---------------------------------------------------------------------------
// Seed epoch
// ---------------------------------------------------------------------------

/// Fixed epoch used for createdAt / updatedAt on all seeded rows.
/// Corresponds to 2025-01-01T00:00:00Z.
const _kSeedEpoch = 1735689600;

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

/// Seeds all default categories into the database using INSERT OR IGNORE.
///
/// Called once from [buildMigrationStrategy]'s `onCreate` callback.
/// INSERT OR IGNORE ensures idempotency: re-running on an already-seeded
/// database produces no duplicates and no errors.
///
/// Parameters:
/// - [database]: The Drift [GeneratedDatabase] whose raw executor is used.
Future<void> seedDefaultCategories(GeneratedDatabase database) async {
  await database.batch((batch) {
    for (final companion in _buildSeedRows()) {
      batch.customStatement(
        'INSERT OR IGNORE INTO categories '
        '(id, parent_id, tree_type, name, icon_ref, '
        'is_deleted, deleted_at, is_protected, sort_order, '
        'created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          companion.id.value,
          companion.parentId.value,
          companion.treeType.value,
          companion.name.value,
          companion.iconRef.value,
          companion.isDeleted.value ? 1 : 0,
          companion.deletedAt.value,
          companion.isProtected.value ? 1 : 0,
          companion.sortOrder.value,
          companion.createdAt.value,
          companion.updatedAt.value,
        ],
      );
    }
  });
}

// ---------------------------------------------------------------------------
// Private builder
// ---------------------------------------------------------------------------

/// Builds the complete list of [CategoriesCompanion] seed rows.
///
/// Returns a flat list containing all income and expense parent and child
/// category rows in the order they should be inserted (parents first so FK
/// constraints are satisfied, although INSERT OR IGNORE also handles
/// out-of-order inserts gracefully).
List<CategoriesCompanion> _buildSeedRows() {
  return [
    ..._incomeParents(),
    ..._incomeChildren(),
    ..._expenseParents(),
    ..._expenseChildren(),
  ];
}

// ---------------------------------------------------------------------------
// Income parents
// ---------------------------------------------------------------------------

List<CategoriesCompanion> _incomeParents() => [
      _row(
        id: _kIncomeStandard,
        treeType: 'income',
        name: 'Standard',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomeGift,
        treeType: 'income',
        name: 'Gift',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomeRepayment,
        treeType: 'income',
        name: 'Repayment',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomeOther,
        treeType: 'income',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Protected: Balance Adjustment income parent
      _row(
        id: _kIncomeBalAdj,
        treeType: 'income',
        name: 'Balance Adjustment',
        iconRef: _kIconBalance,
        isProtected: true,
      ),
    ];

// ---------------------------------------------------------------------------
// Income children
// ---------------------------------------------------------------------------

List<CategoriesCompanion> _incomeChildren() => [
      // Standard children
      _row(
        id: _kIncomeSalary,
        parentId: _kIncomeStandard,
        treeType: 'income',
        name: 'Salary',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomeBonus,
        parentId: _kIncomeStandard,
        treeType: 'income',
        name: 'Bonus',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomeAllowance,
        parentId: _kIncomeStandard,
        treeType: 'income',
        name: 'Allowance',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomeReimbursement,
        parentId: _kIncomeStandard,
        treeType: 'income',
        name: 'Reimbursement',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomeScholarship,
        parentId: _kIncomeStandard,
        treeType: 'income',
        name: 'Scholarship',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomeEpf,
        parentId: _kIncomeStandard,
        treeType: 'income',
        name: 'EPF',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomePension,
        parentId: _kIncomeStandard,
        treeType: 'income',
        name: 'Pension',
        iconRef: _kIconPlaceholder,
      ),
      // Repayment children
      _row(
        id: _kIncomeLoans,
        parentId: _kIncomeRepayment,
        treeType: 'income',
        name: 'Loans',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomeSplitwise,
        parentId: _kIncomeRepayment,
        treeType: 'income',
        name: 'Splitwise',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kIncomeRefund,
        parentId: _kIncomeRepayment,
        treeType: 'income',
        name: 'Refund',
        iconRef: _kIconPlaceholder,
      ),
      // Balance Adjustment income child (BAI) — protected
      _row(
        id: _kIncomeBai,
        parentId: _kIncomeBalAdj,
        treeType: 'income',
        name: 'BAI',
        iconRef: _kIconBalance,
        isProtected: true,
      ),
    ];

// ---------------------------------------------------------------------------
// Expense parents
// ---------------------------------------------------------------------------

List<CategoriesCompanion> _expenseParents() => [
      _row(
        id: _kExpFood,
        treeType: 'expense',
        name: 'Food',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTransportation,
        treeType: 'expense',
        name: 'Transportation',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHousehold,
        treeType: 'expense',
        name: 'Household',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTravels,
        treeType: 'expense',
        name: 'Travels',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpApparel,
        treeType: 'expense',
        name: 'Apparel',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHealth,
        treeType: 'expense',
        name: 'Health',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSelf,
        treeType: 'expense',
        name: 'Self',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSocial,
        treeType: 'expense',
        name: 'Social',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpStationery,
        treeType: 'expense',
        name: 'Stationery',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpCulture,
        treeType: 'expense',
        name: 'Culture',
        iconRef: _kIconPlaceholder,
      ),
      // Financial is not protected; only its "Fees & Charges" child is.
      _row(
        id: _kExpFinancial,
        treeType: 'expense',
        name: 'Financial',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpEducation,
        treeType: 'expense',
        name: 'Education',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpLoan,
        treeType: 'expense',
        name: 'Loan',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFriendsFamily,
        treeType: 'expense',
        name: 'Friends & Family',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpOther,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Protected: Balance Adjustment expense parent
      _row(
        id: _kExpBalAdj,
        treeType: 'expense',
        name: 'Balance Adjustment',
        iconRef: _kIconBalance,
        isProtected: true,
      ),
    ];

// ---------------------------------------------------------------------------
// Expense children
// ---------------------------------------------------------------------------

List<CategoriesCompanion> _expenseChildren() => [
      // Food
      _row(
        id: _kExpFoodLunch,
        parentId: _kExpFood,
        treeType: 'expense',
        name: 'Lunch',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFoodDinner,
        parentId: _kExpFood,
        treeType: 'expense',
        name: 'Dinner',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFoodBreakfast,
        parentId: _kExpFood,
        treeType: 'expense',
        name: 'Breakfast',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFoodSnacks,
        parentId: _kExpFood,
        treeType: 'expense',
        name: 'Snacks',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFoodWater,
        parentId: _kExpFood,
        treeType: 'expense',
        name: 'Water',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFoodEatingOut,
        parentId: _kExpFood,
        treeType: 'expense',
        name: 'Eating Out',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFoodGroceries,
        parentId: _kExpFood,
        treeType: 'expense',
        name: 'Groceries',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFoodSweets,
        parentId: _kExpFood,
        treeType: 'expense',
        name: 'Sweets',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFoodDrinks,
        parentId: _kExpFood,
        treeType: 'expense',
        name: 'Drinks',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFoodOther,
        parentId: _kExpFood,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Transportation
      _row(
        id: _kExpTrnBike,
        parentId: _kExpTransportation,
        treeType: 'expense',
        name: 'Bike',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrnAuto,
        parentId: _kExpTransportation,
        treeType: 'expense',
        name: 'Auto',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrnCab,
        parentId: _kExpTransportation,
        treeType: 'expense',
        name: 'Cab',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrnBus,
        parentId: _kExpTransportation,
        treeType: 'expense',
        name: 'Bus',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrnMetro,
        parentId: _kExpTransportation,
        treeType: 'expense',
        name: 'Metro',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrnFuel,
        parentId: _kExpTransportation,
        treeType: 'expense',
        name: 'Fuel',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrnParking,
        parentId: _kExpTransportation,
        treeType: 'expense',
        name: 'Parking',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrnTolls,
        parentId: _kExpTransportation,
        treeType: 'expense',
        name: 'Tolls',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrnOther,
        parentId: _kExpTransportation,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Household
      _row(
        id: _kExpHseRent,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Rent',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseAppliances,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Appliances',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseToiletries,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Toiletries',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseRepairs,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Repairs',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseMarketing,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Marketing',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseWater,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Water',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseCleaning,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Cleaning',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseFurniture,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Furniture',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseCookMaid,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Cook/Maid',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseKitchen,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Kitchen',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseAccessories,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Accessories',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHseOther,
        parentId: _kExpHousehold,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Travels
      _row(
        id: _kExpTrvTrain,
        parentId: _kExpTravels,
        treeType: 'expense',
        name: 'Train',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrvFlight,
        parentId: _kExpTravels,
        treeType: 'expense',
        name: 'Flight',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrvHotel,
        parentId: _kExpTravels,
        treeType: 'expense',
        name: 'Hotel',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrvEntryFee,
        parentId: _kExpTravels,
        treeType: 'expense',
        name: 'Entry Fee',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrvFood,
        parentId: _kExpTravels,
        treeType: 'expense',
        name: 'Travels Food',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrvTransport,
        parentId: _kExpTravels,
        treeType: 'expense',
        name: 'Travels Transport',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrvGifts,
        parentId: _kExpTravels,
        treeType: 'expense',
        name: 'Gifts & Souvenirs',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpTrvOther,
        parentId: _kExpTravels,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Apparel
      _row(
        id: _kExpAprClothing,
        parentId: _kExpApparel,
        treeType: 'expense',
        name: 'Clothing',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpAprFashion,
        parentId: _kExpApparel,
        treeType: 'expense',
        name: 'Fashion',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpAprShoes,
        parentId: _kExpApparel,
        treeType: 'expense',
        name: 'Shoes',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpAprLaundry,
        parentId: _kExpApparel,
        treeType: 'expense',
        name: 'Laundry',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpAprJewellery,
        parentId: _kExpApparel,
        treeType: 'expense',
        name: 'Jewellery',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpAprAccessories,
        parentId: _kExpApparel,
        treeType: 'expense',
        name: 'Accessories',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpAprOther,
        parentId: _kExpApparel,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Health
      _row(
        id: _kExpHltDoctor,
        parentId: _kExpHealth,
        treeType: 'expense',
        name: 'Doctor',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHltHospital,
        parentId: _kExpHealth,
        treeType: 'expense',
        name: 'Hospital',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHltMedicine,
        parentId: _kExpHealth,
        treeType: 'expense',
        name: 'Medicine',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHltGym,
        parentId: _kExpHealth,
        treeType: 'expense',
        name: 'Gym',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHltHospTransport,
        parentId: _kExpHealth,
        treeType: 'expense',
        name: 'Hospital Transport',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHltHospFood,
        parentId: _kExpHealth,
        treeType: 'expense',
        name: 'Hospital Food',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHltAmbulance,
        parentId: _kExpHealth,
        treeType: 'expense',
        name: 'Ambulance',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHltTests,
        parentId: _kExpHealth,
        treeType: 'expense',
        name: 'Tests',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpHltOther,
        parentId: _kExpHealth,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Self
      _row(
        id: _kExpSlfHaircut,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Haircut',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSlfElecAcc,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Electronic Accessories',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSlfRepair,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Repair',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSlfSubscriptions,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Subscriptions',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSlfTrip,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Trip',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSlfParty,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Party',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSlfBooks,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Books',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSlfToys,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Toys',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSlfGlasses,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Glasses',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSlfGames,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Games',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSlfOther,
        parentId: _kExpSelf,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Social
      _row(
        id: _kExpSocMovie,
        parentId: _kExpSocial,
        treeType: 'expense',
        name: 'Movie',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSocTreat,
        parentId: _kExpSocial,
        treeType: 'expense',
        name: 'Treat',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSocOuting,
        parentId: _kExpSocial,
        treeType: 'expense',
        name: 'Outing',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSocGift,
        parentId: _kExpSocial,
        treeType: 'expense',
        name: 'Gift',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpSocOther,
        parentId: _kExpSocial,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Stationery
      _row(
        id: _kExpStaBooks,
        parentId: _kExpStationery,
        treeType: 'expense',
        name: 'Books',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpStaArt,
        parentId: _kExpStationery,
        treeType: 'expense',
        name: 'Art',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpStaCraft,
        parentId: _kExpStationery,
        treeType: 'expense',
        name: 'Craft',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpStaOther,
        parentId: _kExpStationery,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Culture
      _row(
        id: _kExpCltMusic,
        parentId: _kExpCulture,
        treeType: 'expense',
        name: 'Music',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpCltConcert,
        parentId: _kExpCulture,
        treeType: 'expense',
        name: 'Concert',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpCltMuseum,
        parentId: _kExpCulture,
        treeType: 'expense',
        name: 'Museum',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpCltFestival,
        parentId: _kExpCulture,
        treeType: 'expense',
        name: 'Festival',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpCltPujo,
        parentId: _kExpCulture,
        treeType: 'expense',
        name: 'Pujo',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpCltOther,
        parentId: _kExpCulture,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Financial
      _row(
        id: _kExpFinMobileBill,
        parentId: _kExpFinancial,
        treeType: 'expense',
        name: 'Mobile Bill',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFinWifiBill,
        parentId: _kExpFinancial,
        treeType: 'expense',
        name: 'WiFi Bill',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFinElecBill,
        parentId: _kExpFinancial,
        treeType: 'expense',
        name: 'Electricity Bill',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFinInsurance,
        parentId: _kExpFinancial,
        treeType: 'expense',
        name: 'Insurance',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFinTax,
        parentId: _kExpFinancial,
        treeType: 'expense',
        name: 'Tax',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFinInvestments,
        parentId: _kExpFinancial,
        treeType: 'expense',
        name: 'Investments',
        iconRef: _kIconPlaceholder,
      ),
      // Fees & Charges — protected
      _row(
        id: _kExpFinFeesCharges,
        parentId: _kExpFinancial,
        treeType: 'expense',
        name: 'Fees & Charges',
        iconRef: _kIconPlaceholder,
        isProtected: true,
      ),
      _row(
        id: _kExpFinOther,
        parentId: _kExpFinancial,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Education
      _row(
        id: _kExpEduAppFees,
        parentId: _kExpEducation,
        treeType: 'expense',
        name: 'Application Fees',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpEduTextbooks,
        parentId: _kExpEducation,
        treeType: 'expense',
        name: 'Textbooks',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpEduSupplies,
        parentId: _kExpEducation,
        treeType: 'expense',
        name: 'Supplies',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpEduTuition,
        parentId: _kExpEducation,
        treeType: 'expense',
        name: 'Tuition Fees',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpEduOther,
        parentId: _kExpEducation,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Loan
      _row(
        id: _kExpLonEduLoan,
        parentId: _kExpLoan,
        treeType: 'expense',
        name: 'Education Loan',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpLonHomeLoan,
        parentId: _kExpLoan,
        treeType: 'expense',
        name: 'Home Loan',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpLonPersonal,
        parentId: _kExpLoan,
        treeType: 'expense',
        name: 'Personal Loan',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpLonSpliwise,
        parentId: _kExpLoan,
        treeType: 'expense',
        name: 'Splitwise',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpLonOther,
        parentId: _kExpLoan,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Friends & Family
      _row(
        id: _kExpFrfFriends,
        parentId: _kExpFriendsFamily,
        treeType: 'expense',
        name: 'Friends',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFrfParents,
        parentId: _kExpFriendsFamily,
        treeType: 'expense',
        name: 'Parents',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpFrfOther,
        parentId: _kExpFriendsFamily,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Other
      _row(
        id: _kExpOthHome,
        parentId: _kExpOther,
        treeType: 'expense',
        name: 'Home',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpOthCharity,
        parentId: _kExpOther,
        treeType: 'expense',
        name: 'Charity',
        iconRef: _kIconPlaceholder,
      ),
      _row(
        id: _kExpOthOther,
        parentId: _kExpOther,
        treeType: 'expense',
        name: 'Other',
        iconRef: _kIconPlaceholder,
      ),
      // Balance Adjustment expense child (BAE) — protected
      _row(
        id: _kExpBae,
        parentId: _kExpBalAdj,
        treeType: 'expense',
        name: 'BAE',
        iconRef: _kIconBalance,
        isProtected: true,
      ),
    ];

// ---------------------------------------------------------------------------
// Helper factory
// ---------------------------------------------------------------------------

/// Builds a [CategoriesCompanion] with the given fields and sensible defaults.
CategoriesCompanion _row({
  required String id,
  String? parentId,
  required String treeType,
  required String name,
  required String iconRef,
  bool isProtected = false,
}) {
  return CategoriesCompanion(
    id: Value(id),
    parentId: Value(parentId),
    treeType: Value(treeType),
    name: Value(name),
    iconRef: Value(iconRef),
    isDeleted: const Value(false),
    deletedAt: const Value(null),
    isProtected: Value(isProtected),
    sortOrder: const Value(null),
    createdAt: const Value(_kSeedEpoch),
    updatedAt: const Value(_kSeedEpoch),
  );
}
