/* Autogenerated file, do not edit! */
/* eslint-disable */
import { Contract, ContractBase, DeployMethod, Fr, loadContractArtifact, Point, } from '@aztec/aztec.js';
import FroglinUniverseContractArtifactJson from '../target/froglin_game-FroglinUniverse.json' assert { type: 'json' };
export const FroglinUniverseContractArtifact = loadContractArtifact(FroglinUniverseContractArtifactJson);
/**
 * Type-safe interface for contract FroglinUniverse;
 */
export class FroglinUniverseContract extends ContractBase {
    constructor(instance, wallet) {
        super(instance, FroglinUniverseContractArtifact, wallet);
    }
    /**
     * Creates a contract instance.
     * @param address - The deployed contract's address.
     * @param wallet - The wallet to use when interacting with the contract.
     * @returns A promise that resolves to a new Contract instance.
     */
    static async at(address, wallet) {
        return Contract.at(address, FroglinUniverseContract.artifact, wallet);
    }
    /**
     * Creates a tx to deploy a new instance of this contract.
     */
    static deploy(wallet, gm) {
        return new DeployMethod(Point.ZERO, wallet, FroglinUniverseContractArtifact, FroglinUniverseContract.at, Array.from(arguments).slice(1));
    }
    /**
     * Creates a tx to deploy a new instance of this contract using the specified public key to derive the address.
     */
    static deployWithPublicKey(publicKey, wallet, gm) {
        return new DeployMethod(publicKey, wallet, FroglinUniverseContractArtifact, FroglinUniverseContract.at, Array.from(arguments).slice(2));
    }
    /**
     * Creates a tx to deploy a new instance of this contract using the specified constructor method.
     */
    static deployWithOpts(opts, ...args) {
        return new DeployMethod(opts.publicKey ?? Point.ZERO, opts.wallet, FroglinUniverseContractArtifact, FroglinUniverseContract.at, Array.from(arguments).slice(1), opts.method ?? 'constructor');
    }
    /**
     * Returns this contract's artifact.
     */
    static get artifact() {
        return FroglinUniverseContractArtifact;
    }
    static get storage() {
        return {
            game_master: {
                slot: new Fr(1n),
                typ: "SharedImmutable<AztecAddress>",
            },
            epoch: {
                slot: new Fr(2n),
                typ: "PublicMutable<Epoch>",
            },
            fog: {
                slot: new Fr(4n),
                typ: "PublicMutable<Field>",
            },
            players: {
                slot: new Fr(5n),
                typ: "Map<AztecAddress, PrivateMutable<PlayerNote>>",
            }
        };
    }
    static get notes() {
        const notes = this.artifact.outputs.globals.notes ? this.artifact.outputs.globals.notes : [];
        return {
            PlayerNote: {
                id: new Fr(679711410078111116101n),
            }
        };
    }
}
