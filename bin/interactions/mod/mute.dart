import 'package:nyxx/nyxx.dart';

import '../../obsidian_dart.dart';
import 'package:nyxx_interactions/interactions.dart';

import '../../utils/constants.dart';
import '../../utils/constraints.dart';
import '../../utils/embed.dart';

class ModMuteInteractions {
  ModMuteInteractions() {
    botInteractions
      ..registerSlashCommand(SlashCommandBuilder(
        'mute',
        '<MOD ONLY> Mutes user for a certain time period.',
        [
          CommandOptionBuilder(
              CommandOptionType.user, 'user', 'A server member.',
              required: true),
          CommandOptionBuilder(CommandOptionType.integer, 'time',
              'Time period of mute in minutes.',
              required: true),
          CommandOptionBuilder(
              CommandOptionType.string, 'reason', 'Reason for mute.')
        ],
      )..registerHandler(muteSlashCommand))
      ..registerSlashCommand(SlashCommandBuilder(
        'unmute',
        '<MOD ONLY> Unmutes muted user.',
        [
          CommandOptionBuilder(
              CommandOptionType.user, 'user', 'A server member.',
              required: true),
          CommandOptionBuilder(
              CommandOptionType.string, 'reason', 'Reason for unmute.')
        ],
      )..registerHandler(unmuteSlashCommand));
  }

  Future<void> muteSlashCommand(SlashCommandInteractionEvent event) async {
    await event.acknowledge();

    if (!(await checkForMod(event))) {
      await deleteMessageWithTimer(
        message: await event.sendFollowup(MessageBuilder.embed(
          errorEmbed('Permission Denied!', event.interaction.userAuthor),
        )),
      );
      return;
    }

    final user = event.interaction.resolved?.users.first;
    final time = event.getArg('time').value;
    final reason = event.getArg('reason').value ?? 'No reason provided';
    print('success $user $time $reason');
    final a = await (event.interaction.guild?.getFromCache())
        ?.fetchRoles()
        .cast<Role>()
        .toList();
    print(a);

    final muteEmbed = EmbedBuilder()
      ..title =
          ':mute: Muted user: ${user?.username} for time: **$time** minutes.'
      ..description = '**$reason**'
      ..color = Colors.AUDIT_COLORS['mod']
      ..timestamp = DateTime.now()
      ..addFooter((footer) {
        footer.text = 'Requested by ${event.interaction.userAuthor?.username}';
        footer.iconUrl = event.interaction.userAuthor?.avatarURL();
      });
  }

  Future<void> unmuteSlashCommand(SlashCommandInteractionEvent event) async {
    await event.acknowledge();

    if (!(await checkForMod(event))) {
      await deleteMessageWithTimer(
        message: await event.sendFollowup(MessageBuilder.embed(
          errorEmbed('Permission Denied!', event.interaction.userAuthor),
        )),
      );
      return;
    }

    final user = event.interaction.resolved?.users.first;
    final reason = event.getArg('reason').value ?? 'No reason provided';
  }
}
