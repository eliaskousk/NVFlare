# Copyright (c) 2022, NVIDIA CORPORATION.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import annotations

import enum
from abc import ABC, abstractmethod

from nvflare.fuel.common.ctx import SimpleContext
from nvflare.fuel.hci.table import Table


class CommandCtxKey(object):

    API = "api"
    CMD = "cmd"
    CMD_ENTRY = "cmd_entry"
    CMD_ARGS = "cmd_args"
    REPLY_PROCESSOR = "reply_processor"
    RESULT = "result"
    JSON_PROCESSOR = "json_processor"
    META = "meta"
    CUSTOM_PROPS = "custom_props"
    REQUESTER = "requester"
    CMD_PROPS = "cmd_props"
    CMD_HEADERS = "cmd_headers"


class CommandContext(SimpleContext):
    def set_requester(self, r):
        self.set_prop(CommandCtxKey.REQUESTER, r)

    def get_requester(self):
        return self.get_prop(CommandCtxKey.REQUESTER)

    def set_command_result(self, result):
        self.set_prop(CommandCtxKey.RESULT, result)

    def get_command_result(self):
        return self.get_prop(CommandCtxKey.RESULT)

    def set_api(self, api):
        self.set_prop(CommandCtxKey.API, api)

    def get_api(self):
        return self.get_prop(CommandCtxKey.API)

    def set_command(self, command):
        self.set_prop(CommandCtxKey.CMD, command)

    def get_command(self):
        return self.get_prop(CommandCtxKey.CMD)

    def get_command_name(self):
        args = self.get_command_args()
        full_name = args[0]
        parts = full_name.split(".")
        return parts[-1]

    def set_command_args(self, cmd_args):
        self.set_prop(CommandCtxKey.CMD_ARGS, cmd_args)

    def get_command_args(self):
        return self.get_prop(CommandCtxKey.CMD_ARGS)

    def set_command_entry(self, entry):
        self.set_prop(CommandCtxKey.CMD_ENTRY, entry)

    def get_command_entry(self):
        return self.get_prop(CommandCtxKey.CMD_ENTRY)

    def set_reply_processor(self, processor):
        self.set_prop(CommandCtxKey.REPLY_PROCESSOR, processor)

    def get_reply_processor(self):
        return self.get_prop(CommandCtxKey.REPLY_PROCESSOR)

    def set_json_processor(self, processor):
        self.set_prop(CommandCtxKey.JSON_PROCESSOR, processor)

    def get_json_processor(self):
        return self.get_prop(CommandCtxKey.JSON_PROCESSOR)

    def set_meta(self, meta):
        self.set_prop(CommandCtxKey.META, meta)

    def get_meta(self):
        return self.get_prop(CommandCtxKey.META)

    def set_custom_props(self, value):
        self.set_prop(CommandCtxKey.CUSTOM_PROPS, value)

    def get_custom_props(self):
        return self.get_prop(CommandCtxKey.CUSTOM_PROPS)

    def set_command_props(self, value):
        self.set_prop(CommandCtxKey.CMD_PROPS, value)

    def get_command_props(self):
        return self.get_prop(CommandCtxKey.CMD_PROPS)

    def set_command_headers(self, value):
        self.set_prop(CommandCtxKey.CMD_HEADERS, value)

    def get_command_headers(self):
        return self.get_prop(CommandCtxKey.CMD_HEADERS)


class ApiPocValue(object):
    ADMIN = "admin"


class CommandInfo(enum.Enum):

    OK = 0
    UNKNOWN = 1
    AMBIGUOUS = 2
    CONFIRM_YN = 3
    CONFIRM_AUTH = 4
    CONFIRM_USER_NAME = 5


class ReplyProcessor:
    """A base class for parsing server's response."""

    def reply_start(self, ctx: CommandContext, reply_json):
        pass

    def process_string(self, ctx: CommandContext, item: str):
        pass

    def process_success(self, ctx: CommandContext, item: str):
        pass

    def process_error(self, ctx: CommandContext, err: str):
        pass

    def process_table(self, ctx: CommandContext, table: Table):
        pass

    def process_dict(self, ctx: CommandContext, data: dict):
        pass

    def process_shutdown(self, ctx: CommandContext, msg: str):
        pass

    def process_token(self, ctx: CommandContext, token: str):
        pass

    def protocol_error(self, ctx: CommandContext, err: str):
        pass

    def reply_done(self, ctx: CommandContext):
        pass

    def process_bytes(self, ctx: CommandContext):
        pass


class AdminAPISpec(ABC):
    @abstractmethod
    def is_ready(self) -> bool:
        """Whether the API is ready for executing commands."""
        pass

    @abstractmethod
    def do_command(self, command: str):
        """Executes a command.
        The command could be a client command or a server command.

        Args:
            command: The command to be executed.
        """
        pass

    @abstractmethod
    def server_execute(self, command: str, reply_processor=None, cmd_ctx=None):
        """Executes a command on server side.

        Args:
            command: The command to be executed.
            reply_processor: processor to process reply from server
            cmd_ctx: command context
        """
        pass

    @abstractmethod
    def check_command(self, command: str) -> CommandInfo:
        """Checks the specified command for processing info.
        The command could be a client command or a server command.

        Args:
            command: command to be checked

        Returns: command processing info

        """
        pass


class AdminConfigKey:
    ADMIN = "admin"
    PROJECT_NAME = "project_name"
    IDENTITY = "identity"
    SERVER_IDENTITY = "server_identity"
    CONNECTION_SCHEME = "scheme"
    CONNECTION_SECURITY = "connection_security"
    CLIENT_KEY = "client_key"
    CLIENT_CERT = "client_cert"
    CA_CERT = "ca_cert"
    HOST = "host"
    PORT = "port"
    PROMPT = "prompt"
    LOGIN_TIMEOUT = "login_timeout"
    IDLE_TIMEOUT = "idle_timeout"
    WITH_FILE_TRANSFER = "with_file_transfer"
    CLI_HISTORY_SIZE = "cli_history_size"
    WITH_DEBUG = "with_debug"
    UID_SOURCE = "uid_source"  # where does user id come from
    UPLOAD_DIR = "upload_dir"
    DOWNLOAD_DIR = "download_dir"
    USERNAME = "username"
    FILE_DOWNLOAD_PROGRESS_TIMEOUT = "file_download_progress_timeout"
    AUTHENTICATE_MSG_TIMEOUT = "authenticate_msg_timeout"


class UidSource:
    USER_INPUT = "user_input"  # user must provide
    CERT = "cert"  # CN of the identity certificate
    GUEST = "guest"  # anonymous - for testing purpose


class HCIRequester(ABC):

    @abstractmethod
    def send_request(self, api, conn, cmd_ctx):
        pass
