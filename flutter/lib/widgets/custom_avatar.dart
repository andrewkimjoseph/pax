import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pax/providers/connectivity/connectivity_provider.dart';
import 'package:pax/providers/db/participant/participant_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CustomAvatar extends ConsumerStatefulWidget {
  final double? size;
  final Color? backgroundColor;

  const CustomAvatar({super.key, this.size, this.backgroundColor});

  @override
  ConsumerState<CustomAvatar> createState() => _CustomAvatarState();
}

class _CustomAvatarState extends ConsumerState<CustomAvatar> {
  @override
  Widget build(BuildContext context) {
    final participantState = ref.watch(participantProvider);
    final participant = participantState.participant;
    final connectivity = ref.watch(connectivityProvider);

    final initials = Avatar.getInitials(
      participant?.displayName?.split(" ").first ?? "Participant",
    );

    final provider =
        connectivity.hasInternetConnection &&
                participant != null &&
                participant.profilePictureURI != null &&
                participant.profilePictureURI!.isNotEmpty
            ? CachedNetworkImageProvider(participant.profilePictureURI!)
            : null;

    return Avatar(
      initials: initials,
      provider: provider,
      size: widget.size,
      backgroundColor: widget.backgroundColor,
    );
  }
}
