import 'package:dio/dio.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/interactions.dart';

import '../../obsidian_dart.dart' show botInteractions, dio;
import '../../utils/constants.dart';

class FunWolframInteractions {
  final _imageUrl =
      'http://api.wolframalpha.com/v1/simple?appid=${Tokens.WOLFRAM_ID}&layout=labelbar&background=0C0B0B&foreground=white&width=400';
  final _shortUrl =
      'http://api.wolframalpha.com/v1/result?appid=${Tokens.WOLFRAM_ID}';
  late Map<String, String> _shortParams;

  FunWolframInteractions() {
    botInteractions.registerSlashCommand(SlashCommandBuilder(
      'wolfram',
      'Wolfram group of commands.',
      [
        CommandOptionBuilder(
          CommandOptionType.subCommand,
          'short',
          'Retrieves short answer for the question.',
          options: [
            CommandOptionBuilder(CommandOptionType.string, 'query',
                'The query to ask to the Wolfram API.',
                required: true)
          ],
        )..registerHandler(wolframShortSlashCommand),
        CommandOptionBuilder(
          CommandOptionType.subCommand,
          'image',
          'Retrieves image for the question',
          options: [
            CommandOptionBuilder(CommandOptionType.string, 'query',
                'The query to ask to the Wolfram API.',
                required: true)
          ],
        )..registerHandler(wolframImageSlashCommand)
      ],
    ));
  }

  Future<String> webRequestHandler(
      String url, Map<String, String> params) async {
    late Response response;
    try {
      response = await dio.get(url, queryParameters: params);
    } on DioError catch (err) {
      if (err.response?.statusCode == 400) {
        return 'Sorry, the API did not find any input to interpret.';
      } else if (err.response?.statusCode == 501) {
        return 'Sorry, the API could not understand your input.';
      } else {
        return 'Unidentified error! Status code: ${err.response?.statusCode}, Error: ${err.message}';
      }
    }
    return response.data.toString();
  }

  EmbedBuilder wolframEmbed(
      SlashCommandInteractionEvent event, String title, String desc) {
    return EmbedBuilder()
      ..title = title
      ..description = desc
      ..color = DiscordColor.sapGreen
      ..timestamp = DateTime.now()
      ..addFooter((footer) {
        footer.text = 'Requested by ${event.interaction.userAuthor?.username}';
        footer.iconUrl = event.interaction.userAuthor?.avatarURL();
      });
  }

  Future<void> wolframShortSlashCommand(
      SlashCommandInteractionEvent event) async {
    await event.acknowledge();
    final query = event.getArg('query').value;
    _shortParams = {'i': query};

    final response = await webRequestHandler(_shortUrl, _shortParams);
    final embed =
        wolframEmbed(event, 'Query: $query', 'Response:\n **$response**');
    await event.respond(MessageBuilder.embed(embed));
  }

  Future<void> wolframImageSlashCommand(
      SlashCommandInteractionEvent event) async {
    await event.acknowledge();
    final query = event.getArg('query').value;
    final webQuery = query.trim().replaceAll(' ', '+');

    final response = '$_imageUrl&i=$webQuery';
    final embed = wolframEmbed(
      event,
      'Query: $query',
      '[View original](https://www.wolframalpha.com/input/?i=$webQuery)',
    )..imageUrl = response;

    await event.respond(MessageBuilder.embed(embed));
  }
}
