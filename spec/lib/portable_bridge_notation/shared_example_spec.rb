# For now, place to catch conception of full portable bridge notation
# observer protocol

# guarantee: each method here will be called at most once per
# Importer#import call, *except* with_auction_note, with_play_note,
# and with_commentary, which may be called multiple times per Importer#import
# call, and describe the item causing the immediately preceding call

# #with_event_name(event_name)
# #with_site_name(site_name)
# #with_iso_8601_date(iso_8601_date)
# #with_board_number(board_number)
# #with_player_names(north:, east:, south:, west:)
# #with_dealer_direction(direction)
# #with_vulnerability(north_south:, east_west: )
# #with_dealt_card(direction:, suit:, rank:)
# #with_scoring(scoring_string)
# #with_declarer_direction(direction)
# #with_dummy_and_declarer_swapped()
# #with_contract(contract) # 'AP', '3C', '4NTX', '5SXX', e.g.
# #with_tricks_won(north_south:, east_west:)
# #with_auction_first_call_direction(direction)
# #with_auction_nonbid_call(direction:, call:) # 'AP', 'P', 'X', 'XX'
# #with_auction_bid(direction:, level:, strain:)
# #with_auction_note(note)
# #with_auction_annotation(annotation) # '!', '?', '!!', '??', '!?', '?!'
# #with_first_lead_direction(direction)
# #with_played_card(direction:, suit:, rank:)
# #with_play_note(note)
# #with_play_annotation(annotation)
# #with_commentary(commentary)
